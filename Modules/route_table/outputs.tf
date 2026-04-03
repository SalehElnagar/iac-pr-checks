output "id" {
  value       = azurerm_route_table.this.id
  description = "The route table resource ID."
}

output "name" {
  value       = azurerm_route_table.this.name
  description = "The route table name."
}

output "routes" {
  value = {
    for key, route in azurerm_route.this :
    key => {
      id                     = route.id
      name                   = route.name
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_in_ip_address
    }
  }
  description = "Created routes keyed by logical route name."
}

output "subnet_association_ids" {
  value       = values(azurerm_subnet_route_table_association.this)[*].id
  description = "Route table association IDs."
}

output "tags" {
  value       = azurerm_route_table.this.tags
  description = "The tags applied to the route table."
}
