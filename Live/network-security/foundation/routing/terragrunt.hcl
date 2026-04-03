include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/route_table${include.root.locals.module_source_ref_query}"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name = "RG-CUS-PLATFORM-1-FIREWALL-FOUNDATION-DEV"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "spoke_network" {
  config_path = "../spoke-network"

  mock_outputs = {
    subnets = {
      workload = {
        id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-spoke-vnet/subnets/mock-workload"
        name             = "mock-workload"
        address_prefixes = ["10.20.0.0/26"]
      }
    }
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "firewall" {
  config_path = "../firewall"

  mock_outputs = {
    private_ip_address = "10.10.0.4"
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  foundation = include.root.locals.foundation
  routing    = include.root.locals.network.routing
}

inputs = {
  location                      = include.root.locals.region.location
  resource_group_name           = dependency.resource_group.outputs.name
  namespace                     = local.foundation.namespace
  application                   = local.foundation.application
  environment                   = local.foundation.environment
  environment_instance          = local.foundation.environment_instance
  include_environment           = local.foundation.include_environment
  use_short_environment         = local.foundation.use_short_environment
  purpose                       = local.routing.purpose
  attributes                    = local.routing.attributes
  disable_bgp_route_propagation = local.routing.disable_bgp_route_propagation
  routes = {
    for route_key, route in local.routing.routes :
    route_key => merge(
      route,
      route.next_hop_type == "VirtualAppliance" ? {
        next_hop_in_ip_address = dependency.firewall.outputs.private_ip_address
      } : {}
    )
  }
  subnet_ids = [
    for subnet_key in local.routing.associated_subnet_keys :
    dependency.spoke_network.outputs.subnets[subnet_key].id
  ]
  tags = include.root.locals.merged_tags
}
