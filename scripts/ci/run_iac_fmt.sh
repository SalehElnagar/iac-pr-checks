#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_iac.sh"

parse_common_args "$@"

json_path="$(mktemp)"
discover_targets "${json_path}"

write_fmt_report() {
  local result="$1"
  local terraform_failures_json terragrunt_failures_json report_json
  terraform_failures_json="$(array_json "${terraform_failures[@]}")"
  terragrunt_failures_json="$(array_json "${terragrunt_failures[@]}")"
  report_json="$(
    jq -n \
      --arg job "iac / fmt" \
      --arg result "${result}" \
      --arg mode "$(json_get "${json_path}" '.mode')" \
      --arg effective_mode "$(json_get "${json_path}" '.effective_mode')" \
      --argjson has_relevant_changes "$(json_get "${json_path}" '.has_relevant_changes')" \
      --argjson relevant_changed_files "$(jq '.relevant_changed_files' "${json_path}")" \
      --argjson notes "$(jq '.notes' "${json_path}")" \
      --argjson terraform_checked "$(jq '.terraform.fmt_dirs' "${json_path}")" \
      --argjson terragrunt_checked "$(jq '.terragrunt.fmt_files' "${json_path}")" \
      --argjson terraform_failures "${terraform_failures_json}" \
      --argjson terragrunt_failures "${terragrunt_failures_json}" \
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
          terraform: $terraform_checked,
          terragrunt: $terragrunt_checked
        },
        failures: {
          terraform: $terraform_failures,
          terragrunt: $terragrunt_failures
        }
      }
      '
  )"
  write_report_file "${report_json}"
}

terraform_failures=()
terragrunt_failures=()

if [[ "$(json_get "${json_path}" '.has_relevant_changes')" != "true" ]]; then
  write_fmt_report "success"
  append_no_changes_summary "iac / fmt" "${json_path}"
  append_notes_from_json "${json_path}"
  exit 0
fi

while IFS= read -r dir; do
  [[ -z "${dir}" ]] && continue
  section "terraform fmt ${dir}"
  if ! (cd "${REPO_ROOT}" && "${TF_BIN}" -chdir="${dir}" fmt -check -diff -recursive -no-color); then
    terraform_failures+=("${dir}")
  fi
done < <(json_lines "${json_path}" '.terraform.fmt_dirs')

while IFS= read -r file; do
  [[ -z "${file}" ]] && continue
  section "terragrunt hcl fmt ${file}"
  if ! (cd "${REPO_ROOT}" && "${TERRAGRUNT_BIN}" hcl fmt --check --diff --no-color --file "${file}"); then
    terragrunt_failures+=("${file}")
  fi
done < <(json_lines "${json_path}" '.terragrunt.fmt_files')

result="success"
if (( ${#terraform_failures[@]} > 0 || ${#terragrunt_failures[@]} > 0 )); then
  result="failure"
fi

write_fmt_report "${result}"
append_selection_summary "iac / fmt" "${json_path}" "${result}"
append_list "Terraform fmt checked" $(json_lines "${json_path}" '.terraform.fmt_dirs')
append_list "Terragrunt fmt checked" $(json_lines "${json_path}" '.terragrunt.fmt_files')
append_list "Terraform fmt failures" "${terraform_failures[@]}"
append_list "Terragrunt fmt failures" "${terragrunt_failures[@]}"
append_notes_from_json "${json_path}"

if [[ "${result}" != "success" ]]; then
  exit 1
fi
