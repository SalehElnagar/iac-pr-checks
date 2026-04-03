#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${script_dir}/run_iac_fmt.sh" "$@"
"${script_dir}/run_iac_validate.sh" "$@"
"${script_dir}/run_iac_lint.sh" "$@"
