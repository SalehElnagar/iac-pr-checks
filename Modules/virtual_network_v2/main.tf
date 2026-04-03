resource "azurerm_virtual_network" "this" {
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = local.dns_servers

  tags = local.tags
}

resource "azurerm_subnet" "this" {
  for_each = local.subnet_definitions

  name                 = each.value.resolved_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  service_endpoints                             = try(each.value.service_endpoints, [])
  service_endpoint_policy_ids                   = try(each.value.service_endpoint_policy_ids, null)
  private_endpoint_network_policies_enabled     = try(each.value.private_endpoint_network_policies_enabled, true)
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)

  dynamic "delegation" {
    for_each = try(each.value.delegations, {})

    content {
      name = coalesce(try(delegation.value.name, null), delegation.key)

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = try(delegation.value.service_delegation.actions, [])
      }
    }
  }
}
