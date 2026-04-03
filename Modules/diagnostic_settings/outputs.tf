output "id" {
  value       = azurerm_monitor_diagnostic_setting.this.id
  description = "The diagnostic setting resource ID."
}

output "name" {
  value       = azurerm_monitor_diagnostic_setting.this.name
  description = "The diagnostic setting name."
}
