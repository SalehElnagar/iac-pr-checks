include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/diagnostic_settings${include.root.locals.module_source_ref_query}"
}

dependency "firewall" {
  config_path = "../firewall"

  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/azureFirewalls/mock-firewall"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "log_analytics" {
  config_path = "../log-analytics"

  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.OperationalInsights/workspaces/mock-law"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  foundation         = include.root.locals.foundation
  diagnostic_setting = include.root.locals.diagnostics.diagnostic_setting
}

inputs = {
  location                       = include.root.locals.region.location
  target_resource_id             = dependency.firewall.outputs.id
  log_analytics_workspace_id     = dependency.log_analytics.outputs.id
  log_analytics_destination_type = local.diagnostic_setting.log_analytics_destination_type
  namespace                      = local.foundation.namespace
  environment                    = local.foundation.environment
  environment_instance           = local.foundation.environment_instance
  include_environment            = local.foundation.include_environment
  use_short_environment          = local.foundation.use_short_environment
  purpose                        = local.diagnostic_setting.purpose
  attributes                     = local.diagnostic_setting.attributes
  enabled_logs                   = local.diagnostic_setting.enabled_logs
  metrics                        = local.diagnostic_setting.metrics
}
