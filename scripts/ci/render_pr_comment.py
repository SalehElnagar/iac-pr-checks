#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fmt-report", required=True)
    parser.add_argument("--validate-report", required=True)
    parser.add_argument("--lint-report", required=True)
    parser.add_argument("--fmt-result", required=True)
    parser.add_argument("--validate-result", required=True)
    parser.add_argument("--lint-result", required=True)
    parser.add_argument("--run-url", required=True)
    parser.add_argument("--output", required=True)
    return parser.parse_args()


def normalize_result(value: str) -> str:
    normalized = (value or "unknown").strip().lower()
    mapping = {
        "passed": "success",
        "success": "success",
        "failed": "failure",
        "failure": "failure",
        "cancelled": "cancelled",
        "canceled": "cancelled",
        "skipped": "skipped",
    }
    return mapping.get(normalized, normalized or "unknown")


def pluralize(word: str, count: int) -> str:
    return word if count == 1 else f"{word}s"


def load_report(path_text: str, job_name: str, fallback_result: str) -> dict:
    path = Path(path_text)
    if path.is_file():
        report = json.loads(path.read_text())
    else:
        report = {
            "job": job_name,
            "result": fallback_result,
            "checked": {},
            "failures": {},
            "notes": [],
        }
        fallback_state = normalize_result(fallback_result)
        if fallback_state == "failure":
            report["notes"].append(
                "Detailed target data was unavailable because the job failed before the check script completed."
            )
        elif fallback_state == "cancelled":
            report["notes"].append("The job was cancelled before a detailed target report could be produced.")

    report["job"] = report.get("job") or job_name
    report["result"] = normalize_result(report.get("result", fallback_result))
    report["checked"] = report.get("checked") or {}
    report["failures"] = report.get("failures") or {}
    report["notes"] = report.get("notes") or []
    return report


def scope_text(report: dict) -> str:
    if report.get("has_relevant_changes") is False:
        return "no IaC changes"

    terraform_count = len(report["checked"].get("terraform", []))
    terragrunt_count = len(report["checked"].get("terragrunt", []))
    parts: list[str] = []
    if terraform_count:
        parts.append(f"{terraform_count} Terraform {pluralize('target', terraform_count)}")
    if terragrunt_count:
        parts.append(f"{terragrunt_count} Terragrunt {pluralize('target', terragrunt_count)}")
    return ", ".join(parts) if parts else "no detailed scope"


def format_paths(paths: list[str]) -> str:
    return ", ".join(f"`{path}`" for path in paths)


def issue_lines(report: dict) -> list[str]:
    lines: list[str] = []
    terraform_failures = report["failures"].get("terraform", [])
    terragrunt_failures = report["failures"].get("terragrunt", [])

    if terraform_failures:
        lines.append(f"- Terraform failures: {format_paths(terraform_failures)}")
    if terragrunt_failures:
        lines.append(f"- Terragrunt failures: {format_paths(terragrunt_failures)}")
    if not lines and report["result"] in {"failure", "cancelled"}:
        if report["notes"]:
            lines.extend(f"- {note}" for note in report["notes"])
        else:
            lines.append("- The job failed before it could record target-specific details.")
    return lines


def note_lines(reports: list[dict]) -> list[str]:
    seen: set[str] = set()
    lines: list[str] = []
    for report in reports:
        for note in report.get("notes", []):
            if note == "No Terraform or Terragrunt changes detected.":
                continue
            if note not in seen:
                seen.add(note)
                lines.append(f"- {note}")
    return lines


def render_comment(reports: list[dict], run_url: str) -> str:
    lines = [
        "<!-- iac-pr-checks-summary -->",
        "## IaC PR Checks",
        "",
        "| Check | Result | Scope |",
        "| --- | --- | --- |",
    ]

    for report in reports:
        lines.append(
            f"| `{report['job']}` | `{report['result']}` | {scope_text(report)} |"
        )

    failure_reports = [report for report in reports if report["result"] in {"failure", "cancelled"}]
    if failure_reports:
        lines.extend(["", "### Issues", ""])
        for report in failure_reports:
            lines.append(f"#### `{report['job']}`")
            lines.extend(issue_lines(report))
            lines.append("")

    notes = note_lines(reports)
    if notes:
        lines.extend(["### Notes", ""])
        lines.extend(notes)
        lines.append("")

    lines.append(f"Workflow run: [{run_url}]({run_url})")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = parse_args()
    reports = [
        load_report(args.fmt_report, "iac / fmt", args.fmt_result),
        load_report(args.validate_report, "iac / validate", args.validate_result),
        load_report(args.lint_report, "iac / lint", args.lint_result),
    ]
    body = render_comment(reports, args.run_url)
    Path(args.output).write_text(body)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
