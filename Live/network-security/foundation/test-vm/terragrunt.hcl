include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  foundation = include.root.locals.foundation
  vm         = include.root.locals.vm
}

terraform {
  source = local.vm.enabled ? "${include.root.locals.module_source_prefix}/linux_vm${include.root.locals.module_source_ref_query}" : "${include.root.locals.module_source_prefix}/noop${include.root.locals.module_source_ref_query}"
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
    name                = "mock-spoke-vnet"
    resource_group_name = "mock-rg"
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

inputs = jsondecode(local.vm.enabled ? jsonencode({
  resource_group_name                 = dependency.resource_group.outputs.name
  location                            = include.root.locals.region.location
  virtual_network_resource_group_name = dependency.spoke_network.outputs.resource_group_name
  virtual_network_name                = dependency.spoke_network.outputs.name
  virtual_network_subnet_name         = dependency.spoke_network.outputs.subnets[local.vm.target_subnet_key].name
  namespace                           = local.foundation.namespace
  application                         = local.foundation.application
  environment                         = local.foundation.environment
  attributes                          = local.vm.attributes
  virtual_machine_name                = local.vm.virtual_machine_name
  virtual_machine_purpose             = local.vm.virtual_machine_purpose
  virtual_machine_user_name           = local.vm.admin_username
  virtual_machine_ssh_key_data        = local.vm.ssh_public_keys
  virtual_machine_size                = local.vm.size
  public_ip_create                    = local.vm.public_ip_create
  private_ip_allocation_method        = local.vm.private_ip_allocation_method
  source_image_publisher              = local.vm.source_image.publisher
  source_image_offer                  = local.vm.source_image.offer
  source_image_sku                    = local.vm.source_image.sku
  source_image_version                = local.vm.source_image.version
  tags                                = include.root.locals.merged_tags
}) : "{}")
