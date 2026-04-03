output "local_peering_id" {
  value       = azurerm_virtual_network_peering.local.id
  description = "The local peering resource ID."
}

output "local_peering_name" {
  value       = azurerm_virtual_network_peering.local.name
  description = "The local peering name."
}

output "remote_peering_id" {
  value       = azurerm_virtual_network_peering.remote.id
  description = "The remote peering resource ID."
}

output "remote_peering_name" {
  value       = azurerm_virtual_network_peering.remote.name
  description = "The remote peering name."
}
