# Local Runbook

## Prerequisites

- `terraform` on `PATH`
- `terragrunt` on `PATH`
- `tflint` on `PATH`
- `python3`
- `jq`

Tested locally with:

- Terraform `1.14.7`
- Terragrunt `0.99.4`
- TFLint `0.61.0`

## Fast commands

Run the broader discovered target set:

```bash
./scripts/ci/run_iac_pr_checks.sh --mode full
```

Run the exact live-demo paths:

```bash
./scripts/ci/run_iac_pr_checks.sh --mode path --target-path Live/network-security/foundation/resource-group/terragrunt.hcl
./scripts/ci/run_iac_pr_checks.sh --mode path --target-path Modules/resource_group/versions.tf
```

Run one non-IaC path to show the no-op behavior:

```bash
./scripts/ci/run_iac_fmt.sh --mode path --target-path docs/session/github-pr-checks-demo.md
```

## What to expect

- `fmt` checks only the impacted Terraform modules and changed Terragrunt/shared HCL files without rewriting files.
- `validate` runs Terraform validation for the impacted Terraform modules plus real Terragrunt input/config validation for the impacted units.
- `lint` runs TFLint only for the impacted Terraform modules with no remote module resolution.
- PR comments are updated with the three check results, and failures include the specific module or Terragrunt path that tripped the check when that detail is available.

## Important local note

Most real Terraform modules in this repo consume a shared conventions module over GitHub. The validation helper rewrites SSH GitHub sources to HTTPS at runtime so local runs and CI can validate the real modules without SSH credentials.
