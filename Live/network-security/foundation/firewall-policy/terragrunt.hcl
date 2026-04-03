include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/firewall_policy${include.root.locals.module_source_ref_query}"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name = "RG-CUS-PLATFORM-1-FIREWALL-FOUNDATION-DEV"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  foundation = include.root.locals.foundation
  policy     = include.root.locals.firewall.policy
}

inputs = {
  location                 = include.root.locals.region.location
  resource_group_name      = dependency.resource_group.outputs.name
  namespace                = local.foundation.namespace
  application              = local.foundation.application
  environment              = local.foundation.environment
  environment_instance     = local.foundation.environment_instance
  include_environment      = local.foundation.include_environment
  use_short_environment    = local.foundation.use_short_environment
  purpose                  = local.policy.purpose
  attributes               = local.policy.attributes
  sku                      = local.policy.sku
  threat_intelligence_mode = local.policy.threat_intelligence_mode
  dns                      = local.policy.dns
  rule_collection_groups   = local.policy.rule_collection_groups
  tags                     = include.root.locals.merged_tags
}
