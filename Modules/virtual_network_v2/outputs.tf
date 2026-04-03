output "id" {
  value       = azurerm_virtual_network.this.id
  description = "The virtual network resource ID."
}

output "name" {
  value       = azurerm_virtual_network.this.name
  description = "The virtual network name."
}

output "resource_group_name" {
  value       = azurerm_virtual_network.this.resource_group_name
  description = "The resource group containing the virtual network."
}

output "address_space" {
  value       = azurerm_virtual_network.this.address_space
  description = "The virtual network address spaces."
}

output "dns_servers" {
  value       = azurerm_virtual_network.this.dns_servers
  description = "The DNS servers configured on the virtual network."
}

output "subnets" {
  value = {
    for key, subnet in azurerm_subnet.this :
    key => {
      id               = subnet.id
      name             = subnet.name
      address_prefixes = subnet.address_prefixes
    }
  }
  description = "Subnets keyed by the logical subnet key."
}

output "tags" {
  value       = azurerm_virtual_network.this.tags
  description = "The tags applied to the virtual network."
}
