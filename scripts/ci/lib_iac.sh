#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DISCOVERY_SCRIPT="${REPO_ROOT}/scripts/ci/discover_iac_targets.py"
SUMMARY_FILE="${GITHUB_STEP_SUMMARY:-}"
RESULT_JSON_PATH="${RESULT_JSON_PATH:-}"
TF_BIN="${TF_BIN:-terraform}"
TERRAGRUNT_BIN="${TERRAGRUNT_BIN:-terragrunt}"
TFLINT_BIN="${TFLINT_BIN:-tflint}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
MODE="${MODE:-auto}"
TARGET_PATH="${TARGET_PATH:-}"
EVENT_NAME="${EVENT_NAME:-}"
BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-}"
SCENARIO_LABEL="${SCENARIO_LABEL:-}"

usage_common() {
  cat <<'EOF'
Usage: script [--mode auto|full|path] [--target-path PATH] [--event-name NAME] [--base-sha SHA] [--head-sha SHA] [--default-branch BRANCH] [--scenario LABEL]
EOF
}

parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        MODE="$2"
        shift 2
        ;;
      --target-path)
        TARGET_PATH="$2"
        shift 2
        ;;
      --event-name)
        EVENT_NAME="$2"
        shift 2
        ;;
      --base-sha)
        BASE_SHA="$2"
        shift 2
        ;;
      --head-sha)
        HEAD_SHA="$2"
        shift 2
        ;;
      --default-branch)
        DEFAULT_BRANCH="$2"
        shift 2
        ;;
      --scenario)
        SCENARIO_LABEL="$2"
        shift 2
        ;;
      --help|-h)
        usage_common
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage_common >&2
        exit 2
        ;;
    esac
  done
}

discover_targets() {
  local json_path="$1"
  (
    cd "${REPO_ROOT}"
    python3 "${DISCOVERY_SCRIPT}" \
      --mode "${MODE}" \
      --target-path "${TARGET_PATH}" \
      --event-name "${EVENT_NAME}" \
      --base-sha "${BASE_SHA}" \
      --head-sha "${HEAD_SHA}" \
      --default-branch "${DEFAULT_BRANCH}" \
      >"${json_path}"
  )
}

json_get() {
  local json_path="$1"
  local filter="$2"
  jq -r "${filter}" "${json_path}"
}

json_lines() {
  local json_path="$1"
  local filter="$2"
  jq -r "${filter}[]?" "${json_path}"
}

array_json() {
  if [[ $# -eq 0 ]]; then
    printf '[]\n'
    return
  fi

  printf '%s\n' "$@" | jq -R . | jq -sc '.'
}

write_report_file() {
  local report_json="$1"
  if [[ -n "${RESULT_JSON_PATH}" ]]; then
    printf '%s\n' "${report_json}" >"${RESULT_JSON_PATH}"
  fi
}

run_with_public_github_module_access() {
  GIT_CONFIG_COUNT=2 \
  GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf" \
  GIT_CONFIG_VALUE_0="ssh://git@github.com/" \
  GIT_CONFIG_KEY_1="url.https://github.com/.insteadOf" \
  GIT_CONFIG_VALUE_1="git@github.com:" \
  "$@"
}

append_summary() {
  local content="$1"
  if [[ -n "${SUMMARY_FILE}" ]]; then
    printf '%s\n' "${content}" >>"${SUMMARY_FILE}"
  else
    printf '%s\n' "${content}"
  fi
}

section() {
  local title="$1"
  printf '\n[%s]\n' "${title}"
}

append_selection_summary() {
  local title="$1"
  local json_path="$2"
  local result="$3"
  local fmt_tf_count fmt_tg_count validate_tf_count validate_tg_count lint_count
  fmt_tf_count="$(json_get "${json_path}" '.terraform.fmt_dirs | length')"
  fmt_tg_count="$(json_get "${json_path}" '.terragrunt.fmt_files | length')"
  validate_tf_count="$(json_get "${json_path}" '.terraform.validate_dirs | length')"
  validate_tg_count="$(json_get "${json_path}" '.terragrunt.validate_dirs | length')"
  lint_count="$(json_get "${json_path}" '.terraform.lint_dirs | length')"

  append_summary "## ${title}"
  append_summary ""
  append_summary "- Result: ${result}"
  append_summary "- Mode: \`$(json_get "${json_path}" '.mode')\` (effective: \`$(json_get "${json_path}" '.effective_mode')\`)"
  if [[ -n "${SCENARIO_LABEL}" ]]; then
    append_summary "- Scenario: \`${SCENARIO_LABEL}\`"
  fi
  append_summary "- Terraform fmt dirs: ${fmt_tf_count}"
  append_summary "- Terragrunt fmt files: ${fmt_tg_count}"
  append_summary "- Terraform validate dirs: ${validate_tf_count}"
  append_summary "- Terragrunt validate dirs: ${validate_tg_count}"
  append_summary "- Terraform lint dirs: ${lint_count}"
}

append_no_changes_summary() {
  local title="$1"
  local json_path="$2"
  append_summary "## ${title}"
  append_summary ""
  append_summary "- Result: passed"
  append_summary "- Mode: \`$(json_get "${json_path}" '.mode')\` (effective: \`$(json_get "${json_path}" '.effective_mode')\`)"
  if [[ -n "${SCENARIO_LABEL}" ]]; then
    append_summary "- Scenario: \`${SCENARIO_LABEL}\`"
  fi
  append_summary "- Message: no IaC changes detected"
}

append_list() {
  local label="$1"
  shift
  if [[ $# -eq 0 ]]; then
    return
  fi
  append_summary "- ${label}:"
  while [[ $# -gt 0 ]]; do
    append_summary "  - \`$1\`"
    shift
  done
}

append_notes_from_json() {
  local json_path="$1"
  local note_count
  note_count="$(json_get "${json_path}" '.notes | length')"
  if [[ "${note_count}" == "0" ]]; then
    return
  fi

  append_summary "- Notes:"
  while IFS= read -r note; do
    [[ -z "${note}" ]] && continue
    append_summary "  - ${note}"
  done < <(jq -r '.notes[]?' "${json_path}")
}
