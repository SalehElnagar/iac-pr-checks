output "id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "The Log Analytics workspace resource ID."
}

output "name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "The Log Analytics workspace name."
}

output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.workspace_id
  description = "The customer ID of the Log Analytics workspace."
}

output "location" {
  value       = azurerm_log_analytics_workspace.this.location
  description = "The Azure region of the workspace."
}

output "resource_group_name" {
  value       = azurerm_log_analytics_workspace.this.resource_group_name
  description = "The resource group containing the workspace."
}

output "tags" {
  value       = azurerm_log_analytics_workspace.this.tags
  description = "The tags applied to the workspace."
}
