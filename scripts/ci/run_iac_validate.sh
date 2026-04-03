#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_iac.sh"

parse_common_args "$@"

json_path="$(mktemp)"
discover_targets "${json_path}"

write_validate_report() {
  local result="$1"
  local terraform_failures_json terragrunt_failures_json report_json
  terraform_failures_json="$(array_json "${terraform_failures[@]}")"
  terragrunt_failures_json="$(array_json "${terragrunt_failures[@]}")"
  report_json="$(
    jq -n \
      --arg job "iac / validate" \
      --arg result "${result}" \
      --arg mode "$(json_get "${json_path}" '.mode')" \
      --arg effective_mode "$(json_get "${json_path}" '.effective_mode')" \
      --argjson has_relevant_changes "$(json_get "${json_path}" '.has_relevant_changes')" \
      --argjson relevant_changed_files "$(jq '.relevant_changed_files' "${json_path}")" \
      --argjson notes "$(jq '.notes' "${json_path}")" \
      --argjson terraform_checked "$(jq '.terraform.validate_dirs' "${json_path}")" \
      --argjson terragrunt_checked "$(jq '.terragrunt.validate_dirs' "${json_path}")" \
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
  write_validate_report "success"
  append_no_changes_summary "iac / validate" "${json_path}"
  append_notes_from_json "${json_path}"
  exit 0
fi

while IFS= read -r dir; do
  [[ -z "${dir}" ]] && continue
  section "terraform validate ${dir}"
  init_log="$(mktemp)"
  if ! (cd "${REPO_ROOT}" && TF_IN_AUTOMATION=1 run_with_public_github_module_access "${TF_BIN}" -chdir="${dir}" init -backend=false -input=false -no-color) >"${init_log}" 2>&1; then
    cat "${init_log}"
    rm -f "${init_log}"
    terraform_failures+=("${dir}")
    continue
  fi
  cat "${init_log}"
  rm -f "${init_log}"

  validate_log="$(mktemp)"
  if ! (cd "${REPO_ROOT}" && TF_IN_AUTOMATION=1 run_with_public_github_module_access "${TF_BIN}" -chdir="${dir}" validate -no-color) >"${validate_log}" 2>&1; then
    cat "${validate_log}"
    rm -f "${validate_log}"
    terraform_failures+=("${dir}")
  else
    cat "${validate_log}"
    rm -f "${validate_log}"
  fi
done < <(json_lines "${json_path}" '.terraform.validate_dirs')

while IFS= read -r dir; do
  [[ -z "${dir}" ]] && continue
  section "terragrunt hcl validate ${dir}"
  if ! (cd "${REPO_ROOT}" && TF_IN_AUTOMATION=1 "${TERRAGRUNT_BIN}" hcl validate --inputs --no-color --log-level error --tf-path "${TF_BIN}" --working-dir "${dir}"); then
    terragrunt_failures+=("${dir}")
  fi
done < <(json_lines "${json_path}" '.terragrunt.validate_dirs')

result="success"
if (( ${#terraform_failures[@]} > 0 || ${#terragrunt_failures[@]} > 0 )); then
  result="failure"
fi

write_validate_report "${result}"
append_selection_summary "iac / validate" "${json_path}" "${result}"
append_list "Terraform validate checked" $(json_lines "${json_path}" '.terraform.validate_dirs')
append_list "Terragrunt validate checked" $(json_lines "${json_path}" '.terragrunt.validate_dirs')
append_list "Terraform validate failures" "${terraform_failures[@]}"
append_list "Terragrunt validate failures" "${terragrunt_failures[@]}"
append_notes_from_json "${json_path}"

if [[ "${result}" != "success" ]]; then
  exit 1
fi
