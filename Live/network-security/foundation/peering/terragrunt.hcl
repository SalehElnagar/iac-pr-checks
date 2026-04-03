include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/virtual_network_peering_v2${include.root.locals.module_source_ref_query}"
}

dependency "hub_network" {
  config_path = "../hub-network"

  mock_outputs = {
    id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-hub-vnet"
    name                = "mock-hub-vnet"
    resource_group_name = "mock-rg"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "spoke_network" {
  config_path = "../spoke-network"

  mock_outputs = {
    id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-spoke-vnet"
    name                = "mock-spoke-vnet"
    resource_group_name = "mock-rg"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  foundation = include.root.locals.foundation
  peering    = include.root.locals.network.peering
}

inputs = {
  location                            = include.root.locals.region.location
  namespace                           = local.foundation.namespace
  environment                         = local.foundation.environment
  environment_instance                = local.foundation.environment_instance
  include_environment                 = local.foundation.include_environment
  use_short_environment               = local.foundation.use_short_environment
  local_alias                         = local.peering.local_alias
  remote_alias                        = local.peering.remote_alias
  local_virtual_network_id            = dependency.hub_network.outputs.id
  local_virtual_network_name          = dependency.hub_network.outputs.name
  local_resource_group_name           = dependency.hub_network.outputs.resource_group_name
  remote_virtual_network_id           = dependency.spoke_network.outputs.id
  remote_virtual_network_name         = dependency.spoke_network.outputs.name
  remote_resource_group_name          = dependency.spoke_network.outputs.resource_group_name
  local_allow_virtual_network_access  = local.peering.hub_to_spoke.allow_virtual_network_access
  local_allow_forwarded_traffic       = local.peering.hub_to_spoke.allow_forwarded_traffic
  local_allow_gateway_transit         = local.peering.hub_to_spoke.allow_gateway_transit
  local_use_remote_gateways           = local.peering.hub_to_spoke.use_remote_gateways
  remote_allow_virtual_network_access = local.peering.spoke_to_hub.allow_virtual_network_access
  remote_allow_forwarded_traffic      = local.peering.spoke_to_hub.allow_forwarded_traffic
  remote_allow_gateway_transit        = local.peering.spoke_to_hub.allow_gateway_transit
  remote_use_remote_gateways          = local.peering.spoke_to_hub.use_remote_gateways
}
