# Live Demo Kit

This folder contains repeatable break/fix patches for the session.

## Quick start

Start every scenario from a clean branch based on `main`.

```bash
git checkout main
git checkout -b demo/format-fail
git apply demo/session/patches/01-format-break.patch
```

Push the branch and open a PR to show the failing check. Then apply the matching fix patch:

```bash
git apply demo/session/patches/01-format-fix.patch
```

Repeat with new branches for the validation and lint scenarios:

```bash
git checkout main
git checkout -b demo/validate-fail
git apply demo/session/patches/02-validate-break.patch

git checkout main
git checkout -b demo/lint-fail
git apply demo/session/patches/03-lint-break.patch
```

## Patch inventory

- [demo/session/patches/01-format-break.patch](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/patches/01-format-break.patch)
- [demo/session/patches/01-format-fix.patch](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/patches/01-format-fix.patch)
- [demo/session/patches/02-validate-break.patch](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/patches/02-validate-break.patch)
- [demo/session/patches/02-validate-fix.patch](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/patches/02-validate-fix.patch)
- [demo/session/patches/03-lint-break.patch](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/patches/03-lint-break.patch)
- [demo/session/patches/03-lint-fix.patch](/Users/salehelnagar/Workspace/platform/iac-pr-checks/demo/session/patches/03-lint-fix.patch)

## Scenario map

- Formatting failure: [Live/network-security/foundation/resource-group/terragrunt.hcl](/Users/salehelnagar/Workspace/platform/iac-pr-checks/Live/network-security/foundation/resource-group/terragrunt.hcl)
- Validation failure: [Live/network-security/foundation/resource-group/terragrunt.hcl](/Users/salehelnagar/Workspace/platform/iac-pr-checks/Live/network-security/foundation/resource-group/terragrunt.hcl)
- Lint failure: [Modules/resource_group/versions.tf](/Users/salehelnagar/Workspace/platform/iac-pr-checks/Modules/resource_group/versions.tf)

Each patch is intentionally tiny so the PR diff stays easy to narrate live.
