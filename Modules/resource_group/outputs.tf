output "id" {
  value       = azurerm_resource_group.this.id
  description = "The resource group resource ID."
}

output "name" {
  value       = azurerm_resource_group.this.name
  description = "The resource group name."
}

output "location" {
  value       = azurerm_resource_group.this.location
  description = "The Azure region of the resource group."
}

output "tags" {
  value       = azurerm_resource_group.this.tags
  description = "The tags applied to the resource group."
}
