output "id" {
  value       = azurerm_firewall_policy.this.id
  description = "The firewall policy resource ID."
}

output "name" {
  value       = azurerm_firewall_policy.this.name
  description = "The firewall policy name."
}

output "rule_collection_group_ids" {
  value = {
    for key, group in azurerm_firewall_policy_rule_collection_group.this :
    key => group.id
  }
  description = "Rule collection group IDs keyed by logical group name."
}

output "rule_collection_group_names" {
  value = {
    for key, group in azurerm_firewall_policy_rule_collection_group.this :
    key => group.name
  }
  description = "Rule collection group names keyed by logical group name."
}

output "tags" {
  value       = azurerm_firewall_policy.this.tags
  description = "The tags applied to the firewall policy."
}
