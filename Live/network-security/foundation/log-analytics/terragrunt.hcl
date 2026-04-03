include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/log_analytics_workspace${include.root.locals.module_source_ref_query}"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name     = "RG-CUS-PLATFORM-1-FIREWALL-FOUNDATION-DEV"
    location = include.root.locals.region.location
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  foundation = include.root.locals.foundation
  workspace  = include.root.locals.diagnostics.workspace
}

inputs = {
  location                   = include.root.locals.region.location
  resource_group_name        = dependency.resource_group.outputs.name
  namespace                  = local.foundation.namespace
  application                = local.foundation.application
  environment                = local.foundation.environment
  environment_instance       = local.foundation.environment_instance
  include_environment        = local.foundation.include_environment
  use_short_environment      = local.foundation.use_short_environment
  purpose                    = local.workspace.purpose
  attributes                 = local.workspace.attributes
  sku                        = local.workspace.sku
  retention_in_days          = local.workspace.retention_in_days
  daily_quota_gb             = local.workspace.daily_quota_gb
  internet_ingestion_enabled = local.workspace.internet_ingestion_enabled
  internet_query_enabled     = local.workspace.internet_query_enabled
  tags                       = include.root.locals.merged_tags
}
