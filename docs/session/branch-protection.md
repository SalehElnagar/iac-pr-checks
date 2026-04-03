# Branch Protection And Required Checks

## Workflow

- Workflow file: [`.github/workflows/iac-pr-checks.yml`](/Users/salehelnagar/Workspace/platform/iac-pr-checks/.github/workflows/iac-pr-checks.yml)
- Stable visible job names:
  - `iac / fmt`
  - `iac / validate`
  - `iac / lint`

## Required status checks

Mark these three jobs as required in branch protection:

- `iac / fmt`
- `iac / validate`
- `iac / lint`

Do not key branch protection to the workflow name alone. Use the exact job names above so the required checks stay stable even if the workflow grows internally.

## Why there is no workflow-level paths filter

The workflow runs for every PR and push to `main`, then each job performs its own target discovery.

Benefits:

- required checks always appear consistently on PRs
- changed IaC runs stay scoped to the impacted Terraform modules and Terragrunt targets
- no-IaC changes exit quickly with a passing summary instead of silently skipping the workflow entirely

Normal `auto` mode does not fan out across the whole repo. It resolves only the impacted Terraform module roots, Terragrunt units, and related shared stack files. If you want the broader discovered target set, use `workflow_dispatch` with `mode=full`.

## Validation behavior

- Terragrunt validation runs against the real live units under [Live/network-security/foundation](/Users/salehelnagar/Workspace/platform/iac-pr-checks/Live/network-security/foundation).
- Terraform validation auto-discovers Terraform roots from the repo and validates them directly.
- During validation, the helper rewrites GitHub SSH sources to HTTPS at runtime so public pinned tags can be fetched in CI without SSH credentials.

## Manual workflow dispatch

Use the `workflow_dispatch` inputs when you want to demo or troubleshoot without opening a new PR:

- `mode=auto`: changed targets only
- `mode=full`: all discovered targets
- `mode=path`: one repo-relative path plus any directly related targets

`target_path` is only required when `mode=path`. `scenario` is optional and only affects the job summaries.
