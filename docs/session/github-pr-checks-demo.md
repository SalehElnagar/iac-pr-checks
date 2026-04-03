# Automating Terraform Quality with GitHub Pull Request Checks

This repo now has one conference-ready workflow at [`.github/workflows/iac-pr-checks.yml`](/Users/salehelnagar/Workspace/platform/iac-pr-checks/.github/workflows/iac-pr-checks.yml) with three visible jobs:

- `iac / fmt`
- `iac / validate`
- `iac / lint`

## Demo-safe paths to show on screen

- [Live/network-security/foundation/resource-group/terragrunt.hcl](/Users/salehelnagar/Workspace/platform/iac-pr-checks/Live/network-security/foundation/resource-group/terragrunt.hcl)
- [Modules/resource_group/versions.tf](/Users/salehelnagar/Workspace/platform/iac-pr-checks/Modules/resource_group/versions.tf)

## What each job demonstrates

- `iac / fmt`: `terraform fmt -check -diff -recursive -no-color` on selected Terraform roots plus `terragrunt hcl fmt --check --diff` on selected HCL files.
- `iac / validate`: `terraform init -backend=false` and `terraform validate` on the selected real Terraform roots, plus real `terragrunt hcl validate --inputs` for the live Terragrunt units.
- `iac / lint`: TFLint with an explicit, deterministic rule set and `--call-module-type=none` to avoid remote module fetches.

## Recommended live sequence

1. Show a clean run with `workflow_dispatch` in `path` or `full` mode, or by running [demo/session/README.md](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/README.md) locally.
2. Apply the formatting patch, push a PR, and show only `iac / fmt` failing.
3. Apply the formatting fix patch, then apply the validation patch, push again, and show only `iac / validate` failing.
4. Apply the validation fix patch, then apply the lint patch, push again, and show only `iac / lint` failing.
5. Apply the lint fix patch and finish on an all-green PR.

## Notes to explain during the session

- The workflow intentionally has no top-level `paths` filter. It always runs on PRs, pushes to `main`, and manual dispatches, then each job decides whether it has IaC work to do.
- If no relevant Terraform or Terragrunt files changed, each job exits quickly and writes a clear "no IaC changes detected" summary.
- Real Terragrunt validation is broad because the live units already use mocked dependency outputs for `validate`.
- Real Terraform validation runs against the actual discovered module roots. GitHub SSH sources are rewritten to HTTPS at runtime so public pinned tags can be fetched in CI without SSH keys.
