include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/azure_firewall_v2${include.root.locals.module_source_ref_query}"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name = "RG-CUS-PLATFORM-1-FIREWALL-FOUNDATION-DEV"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "hub_network" {
  config_path = "../hub-network"

  mock_outputs = {
    subnets = {
      firewall = {
        id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-hub-vnet/subnets/AzureFirewallSubnet"
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.10.0.0/26"]
      }
    }
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "firewall_policy" {
  config_path = "../firewall-policy"

  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/firewallPolicies/mock-policy"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  foundation = include.root.locals.foundation
  firewall   = include.root.locals.firewall.firewall
}

inputs = {
  location              = include.root.locals.region.location
  resource_group_name   = dependency.resource_group.outputs.name
  subnet_id             = dependency.hub_network.outputs.subnets.firewall.id
  firewall_policy_id    = dependency.firewall_policy.outputs.id
  namespace             = local.foundation.namespace
  application           = local.foundation.application
  environment           = local.foundation.environment
  environment_instance  = local.foundation.environment_instance
  include_environment   = local.foundation.include_environment
  use_short_environment = local.foundation.use_short_environment
  purpose               = local.firewall.purpose
  attributes            = local.firewall.attributes
  public_ip_purpose     = local.firewall.public_ip_purpose
  public_ip_attributes  = local.firewall.public_ip_attributes
  sku_tier              = local.firewall.sku_tier
  zones                 = length(local.firewall.zones) > 0 ? local.firewall.zones : null
  public_ip_zones       = length(local.firewall.public_ip_zones) > 0 ? local.firewall.public_ip_zones : null
  tags                  = include.root.locals.merged_tags
}
