# Terraform Modules

This tree contains the deployable modules published with the Azure Firewall article series. Shared naming and tagging logic comes from the separately published `terraform-conventions` repository.

## Published scope

- `resource_group`
- `log_analytics_workspace`
- `virtual_network_v2`
- `virtual_network_peering_v2`
- `firewall_policy`
- `azure_firewall_v2`
- `route_table`
- `diagnostic_settings`
- `linux_vm`
- `noop`

## Release model

The current consumption model is:

1. `terraform-conventions` is published and versioned independently.
2. Module internals consume the conventions library through pinned `git::ssh://...//conventions/modules/<module>?ref=v0.2.0` sources.
3. Terragrunt consumes these modules from `git::ssh://git@github.com/SalehElnagar/azure-firewall-series.git//Modules/<module>?ref=<tag>`.
