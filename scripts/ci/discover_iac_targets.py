#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Iterable


ZERO_SHA = "0" * 40
LIVE_ROOT = Path("Live")
EXCLUDE_DIR_NAMES = frozenset(
    {
        ".git",
        ".github",
        ".terraform",
        ".terragrunt-cache",
        ".idea",
        ".vscode",
        "__pycache__",
        "vendor",
        "node_modules",
    }
)
IGNORE_FILE_NAMES = frozenset({".terraform.lock.hcl"})
CONTROL_PATHS = (
    ".github/workflows/iac-pr-checks.yml",
    ".tflint.hcl",
    "scripts/ci/",
)


def run_git(repo_root: Path, *args: str, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if check and result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result.stdout


def normalize(path_value: str | Path) -> str:
    path = Path(path_value)
    try:
        return path.relative_to(".").as_posix()
    except ValueError:
        return path.as_posix()


def is_excluded(path: Path) -> bool:
    path_str = path.as_posix()
    for control_path in CONTROL_PATHS:
        if path_str == control_path or path_str.startswith(control_path):
            return False
    if path.name in IGNORE_FILE_NAMES:
        return True
    return any(part in EXCLUDE_DIR_NAMES for part in path.parts)


def is_control_path(path_text: str) -> bool:
    return any(
        path_text == control_path or path_text.startswith(control_path)
        for control_path in CONTROL_PATHS
    )


def list_terraform_dirs(repo_root: Path) -> list[str]:
    dirs: set[str] = set()
    for path in repo_root.rglob("*.tf"):
        relative = path.relative_to(repo_root)
        if is_excluded(relative):
            continue
        dirs.add(relative.parent.as_posix())
    return sorted(dirs)


def terragrunt_fmt_files(repo_root: Path) -> list[str]:
    files: set[str] = set()
    for path in repo_root.rglob("terragrunt.hcl"):
        relative = path.relative_to(repo_root)
        if is_excluded(relative):
            continue
        files.add(relative.as_posix())
    root_hcl = repo_root / "Live/root.hcl"
    if root_hcl.is_file():
        files.add("Live/root.hcl")
    return sorted(files)


def live_unit_dirs(repo_root: Path) -> list[str]:
    dirs: set[str] = set()
    for path in repo_root.joinpath("Live").rglob("terragrunt.hcl"):
        relative = path.relative_to(repo_root)
        if is_excluded(relative):
            continue
        if relative.parts[0] != "Live" or relative.name != "terragrunt.hcl":
            continue
        if len(relative.parts) >= 5:
            dirs.add(relative.parent.as_posix())
    return sorted(dirs)


def module_to_units(repo_root: Path, units: list[str]) -> dict[str, list[str]]:
    mapping: dict[str, set[str]] = {}
    for unit in units:
        terragrunt_file = repo_root / unit / "terragrunt.hcl"
        content = terragrunt_file.read_text()
        marker = 'locals.module_source_prefix}/'
        if marker not in content:
            continue
        fragment = content.split(marker, 1)[1]
        module_name = fragment.split("${", 1)[0].split('"', 1)[0].strip("/")
        if not module_name:
            continue
        mapping.setdefault(module_name, set()).add(unit)
    return {key: sorted(values) for key, values in sorted(mapping.items())}


def stack_root(unit_dir: str) -> str:
    parts = Path(unit_dir).parts
    return Path(*parts[:-1]).as_posix()


def all_units_in_stack(units: Iterable[str], wanted_stack_root: str) -> list[str]:
    return sorted(unit for unit in units if stack_root(unit) == wanted_stack_root)


def parse_status_paths(repo_root: Path) -> list[str]:
    output = run_git(repo_root, "status", "--porcelain", "--untracked-files=all", check=False)
    changed: list[str] = []
    for raw_line in output.splitlines():
        if not raw_line:
            continue
        path_text = raw_line[3:]
        if " -> " in path_text:
            path_text = path_text.split(" -> ", 1)[1]
        changed.append(path_text)
    return changed


def diff_paths(repo_root: Path, base_sha: str | None, head_sha: str | None, default_branch: str) -> list[str]:
    if base_sha and base_sha != ZERO_SHA and head_sha:
        diff_output = run_git(repo_root, "diff", "--name-only", base_sha, head_sha, check=False)
        return diff_output.splitlines()

    candidates = [f"origin/{default_branch}", default_branch]
    for candidate in candidates:
        candidate = candidate.strip()
        if not candidate:
            continue
        result = subprocess.run(
            ["git", "rev-parse", "--verify", candidate],
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            continue
        merge_base = run_git(repo_root, "merge-base", "HEAD", candidate, check=False).strip()
        if merge_base:
            diff_output = run_git(repo_root, "diff", "--name-only", merge_base, "HEAD", check=False)
            return diff_output.splitlines()

    return []


def unique_sorted(values: Iterable[str]) -> list[str]:
    return sorted({value for value in values if value})


def empty_selection(mode: str, effective_mode: str, changed_files: list[str]) -> dict:
    return {
        "mode": mode,
        "effective_mode": effective_mode,
        "changed_files": changed_files,
        "relevant_changed_files": [],
        "has_relevant_changes": False,
        "terraform": {
            "fmt_dirs": [],
            "validate_dirs": [],
            "lint_dirs": [],
        },
        "terragrunt": {
            "fmt_files": [],
            "validate_dirs": [],
        },
        "notes": ["No Terraform or Terragrunt changes detected."],
    }


def build_full_selection(repo_root: Path, terraform_dirs: list[str]) -> dict:
    return {
        "terraform": {
            "fmt_dirs": terraform_dirs,
            "validate_dirs": terraform_dirs,
            "lint_dirs": terraform_dirs,
        },
        "terragrunt": {
            "fmt_files": terragrunt_fmt_files(repo_root),
            "validate_dirs": live_unit_dirs(repo_root),
        },
    }


def add_path_selection(
    path_text: str,
    repo_root: Path,
    terraform_roots: list[str],
    units: list[str],
    module_units: dict[str, list[str]],
    selection: dict,
    relevant_changed_files: set[str],
) -> None:
    path = Path(path_text)
    path_str = path.as_posix()

    matching_root = next(
        (
            root
            for root in sorted(terraform_roots, key=len, reverse=True)
            if path_str == root or path_str.startswith(f"{root}/")
        ),
        None,
    )
    if matching_root:
        relevant_changed_files.add(path_str)
        module_dir = matching_root
        selection["terraform"]["fmt_dirs"].add(module_dir)
        selection["terraform"]["lint_dirs"].add(module_dir)
        selection["terraform"]["validate_dirs"].add(module_dir)

        module_name = Path(module_dir).name
        for unit_dir in module_units.get(module_name, []):
            selection["terragrunt"]["validate_dirs"].add(unit_dir)
        return

    if path_str == "Live/root.hcl":
        relevant_changed_files.add(path_str)
        selection["terragrunt"]["fmt_files"].add("Live/root.hcl")
        selection["terragrunt"]["validate_dirs"].update(units)
        return

    if path_str.endswith("terragrunt.hcl"):
        relevant_changed_files.add(path_str)
        selection["terragrunt"]["fmt_files"].add(path_str)
        selection["terragrunt"]["validate_dirs"].add(str(Path(path_str).parent))
        return

    if path_str.startswith("Live/") and Path(path_str).suffix in {".yaml", ".yml", ".hcl"}:
        relevant_changed_files.add(path_str)
        target = Path(path_str)
        if len(target.parts) >= 4 and target.parts[0] == "Live":
            base_stack_root = Path(*target.parts[:-1]).as_posix()
            stack_units = all_units_in_stack(units, base_stack_root)
            if stack_units:
                selection["terragrunt"]["validate_dirs"].update(stack_units)
                if target.suffix == ".hcl":
                    selection["terragrunt"]["fmt_files"].add(path_str)
                return
        selection["terragrunt"]["validate_dirs"].update(units)
        if target.suffix == ".hcl":
            selection["terragrunt"]["fmt_files"].add(path_str)


def finalize_selection(
    mode: str,
    effective_mode: str,
    changed_files: list[str],
    relevant_changed_files: set[str],
    selection: dict,
) -> dict:
    result = {
        "mode": mode,
        "effective_mode": effective_mode,
        "changed_files": changed_files,
        "relevant_changed_files": sorted(relevant_changed_files),
        "has_relevant_changes": bool(relevant_changed_files),
        "terraform": {
            "fmt_dirs": unique_sorted(selection["terraform"]["fmt_dirs"]),
            "validate_dirs": unique_sorted(selection["terraform"]["validate_dirs"]),
            "lint_dirs": unique_sorted(selection["terraform"]["lint_dirs"]),
        },
        "terragrunt": {
            "fmt_files": unique_sorted(selection["terragrunt"]["fmt_files"]),
            "validate_dirs": unique_sorted(selection["terragrunt"]["validate_dirs"]),
        },
        "notes": selection["notes"],
    }
    if not result["has_relevant_changes"]:
        result["notes"].append("No Terraform or Terragrunt changes detected.")
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["auto", "full", "path"], default="auto")
    parser.add_argument("--target-path")
    parser.add_argument("--event-name", default="")
    parser.add_argument("--base-sha", default="")
    parser.add_argument("--head-sha", default="")
    parser.add_argument("--default-branch", default="main")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    terraform_dirs = list_terraform_dirs(repo_root)
    units = live_unit_dirs(repo_root)
    module_units = module_to_units(repo_root, units)

    if args.mode == "full":
        selection = build_full_selection(repo_root, terraform_dirs)
        result = {
            "mode": args.mode,
            "effective_mode": "full",
            "changed_files": [],
            "relevant_changed_files": [],
            "has_relevant_changes": True,
            "terraform": selection["terraform"],
            "terragrunt": selection["terragrunt"],
            "notes": ["Full mode selected all discovered targets."],
        }
    else:
        if args.mode == "path":
            if not args.target_path:
                raise SystemExit("--target-path is required when mode=path")
            changed_files = [normalize(args.target_path)]
        else:
            changed_files = unique_sorted(
                normalize(path)
                for path in diff_paths(repo_root, args.base_sha, args.head_sha, args.default_branch)
                + parse_status_paths(repo_root)
            )

        changed_files = [
            path
            for path in changed_files
            if path and not is_excluded(Path(path))
        ]
        if not changed_files:
            result = empty_selection(args.mode, args.mode, changed_files)
        else:
            selection = {
                "terraform": {
                    "fmt_dirs": set(),
                    "validate_dirs": set(),
                    "lint_dirs": set(),
                },
                "terragrunt": {
                    "fmt_files": set(),
                    "validate_dirs": set(),
                },
                "notes": [],
            }
            relevant_changed_files: set[str] = set()
            control_path_changes = [path for path in changed_files if is_control_path(path)]
            if control_path_changes:
                selection["notes"].append(
                    "CI control files changed; auto mode still scopes checks to changed IaC targets only. "
                    "Use workflow_dispatch with mode=full when you want to exercise the full discovered target set."
                )
            for path in changed_files:
                add_path_selection(path, repo_root, terraform_dirs, units, module_units, selection, relevant_changed_files)

            result = finalize_selection(args.mode, args.mode, changed_files, relevant_changed_files, selection)

    print(json.dumps(result, indent=2, sort_keys=True))

    summary_lines = [
        f"Mode: {result['mode']} (effective: {result['effective_mode']})",
        f"Changed files considered: {len(result['changed_files'])}",
        f"Relevant IaC changes: {'yes' if result['has_relevant_changes'] else 'no'}",
        f"Terraform fmt dirs: {len(result['terraform']['fmt_dirs'])}",
        f"Terraform validate dirs: {len(result['terraform']['validate_dirs'])}",
        f"Terraform lint dirs: {len(result['terraform']['lint_dirs'])}",
        f"Terragrunt fmt files: {len(result['terragrunt']['fmt_files'])}",
        f"Terragrunt validate dirs: {len(result['terragrunt']['validate_dirs'])}",
    ]
    if result["notes"]:
        summary_lines.append(f"Notes: {' | '.join(result['notes'])}")
    print("\n".join(summary_lines), file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
