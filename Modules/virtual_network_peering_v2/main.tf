resource "azurerm_virtual_network_peering" "local" {
  name                         = local.local_name
  resource_group_name          = var.local_resource_group_name
  virtual_network_name         = var.local_virtual_network_name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = var.local_allow_virtual_network_access
  allow_forwarded_traffic      = var.local_allow_forwarded_traffic
  allow_gateway_transit        = var.local_allow_gateway_transit
  use_remote_gateways          = var.local_use_remote_gateways
}

resource "azurerm_virtual_network_peering" "remote" {
  name                         = local.remote_name
  resource_group_name          = var.remote_resource_group_name
  virtual_network_name         = var.remote_virtual_network_name
  remote_virtual_network_id    = var.local_virtual_network_id
  allow_virtual_network_access = var.remote_allow_virtual_network_access
  allow_forwarded_traffic      = var.remote_allow_forwarded_traffic
  allow_gateway_transit        = var.remote_allow_gateway_transit
  use_remote_gateways          = var.remote_use_remote_gateways
}
