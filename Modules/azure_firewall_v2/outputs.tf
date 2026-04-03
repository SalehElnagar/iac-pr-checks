output "id" {
  value       = azurerm_firewall.this.id
  description = "The firewall resource ID."
}

output "name" {
  value       = azurerm_firewall.this.name
  description = "The firewall name."
}

output "private_ip_address" {
  value       = try(one([for ip in azurerm_firewall.this.ip_configuration : ip.private_ip_address if ip.private_ip_address != null]), null)
  description = "The firewall private IP address."
}

output "public_ip_id" {
  value       = azurerm_public_ip.this.id
  description = "The firewall public IP resource ID."
}

output "public_ip_name" {
  value       = azurerm_public_ip.this.name
  description = "The firewall public IP name."
}

output "public_ip_address" {
  value       = azurerm_public_ip.this.ip_address
  description = "The firewall public IP address."
}

output "resource_group_name" {
  value       = azurerm_firewall.this.resource_group_name
  description = "The resource group containing the firewall."
}

output "firewall_policy_id" {
  value       = azurerm_firewall.this.firewall_policy_id
  description = "The firewall policy associated with the firewall."
}

output "tags" {
  value       = azurerm_firewall.this.tags
  description = "The tags applied to the firewall."
}
