#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_iac.sh"

parse_common_args "$@"

json_path="$(mktemp)"
discover_targets "${json_path}"

lint_failures=()

write_lint_report() {
  local result="$1"
  local lint_failures_json report_json
  lint_failures_json="$(array_json "${lint_failures[@]}")"
  report_json="$(
    jq -n \
      --arg job "iac / lint" \
      --arg result "${result}" \
      --arg mode "$(json_get "${json_path}" '.mode')" \
      --arg effective_mode "$(json_get "${json_path}" '.effective_mode')" \
      --argjson has_relevant_changes "$(json_get "${json_path}" '.has_relevant_changes')" \
      --argjson relevant_changed_files "$(jq '.relevant_changed_files' "${json_path}")" \
      --argjson notes "$(jq '.notes' "${json_path}")" \
      --argjson terraform_checked "$(jq '.terraform.lint_dirs' "${json_path}")" \
      --argjson terraform_failures "${lint_failures_json}" \
      '
      {
        job: $job,
        result: $result,
        mode: $mode,
        effective_mode: $effective_mode,
        has_relevant_changes: $has_relevant_changes,
        relevant_changed_files: $relevant_changed_files,
        notes: $notes,
        checked: {
          terraform: $terraform_checked
        },
        failures: {
          terraform: $terraform_failures
        }
      }
      '
  )"
  write_report_file "${report_json}"
}

if [[ "$(json_get "${json_path}" '.has_relevant_changes')" != "true" ]]; then
  write_lint_report "success"
  append_no_changes_summary "iac / lint" "${json_path}"
  append_notes_from_json "${json_path}"
  exit 0
fi

while IFS= read -r dir; do
  [[ -z "${dir}" ]] && continue
  section "tflint ${dir}"
  if ! (cd "${REPO_ROOT}" && "${TFLINT_BIN}" --chdir="${dir}" --config="${REPO_ROOT}/.tflint.hcl" --call-module-type=none --no-color); then
    lint_failures+=("${dir}")
  fi
done < <(json_lines "${json_path}" '.terraform.lint_dirs')

result="success"
if (( ${#lint_failures[@]} > 0 )); then
  result="failure"
fi

write_lint_report "${result}"
append_selection_summary "iac / lint" "${json_path}" "${result}"
append_list "TFLint checked" $(json_lines "${json_path}" '.terraform.lint_dirs')
append_list "TFLint failures" "${lint_failures[@]}"
append_notes_from_json "${json_path}"

if [[ "${result}" != "success" ]]; then
  exit 1
fi
