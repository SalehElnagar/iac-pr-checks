resource "azurerm_firewall_policy" "this" {
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  base_policy_id      = var.base_policy_id

  threat_intelligence_mode = var.threat_intelligence_mode

  dynamic "dns" {
    for_each = var.dns != null ? [var.dns] : []

    content {
      proxy_enabled = try(dns.value.proxy_enabled, false)
      servers       = try(dns.value.servers, [])
    }
  }

  tags = local.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each = var.rule_collection_groups

  name               = module.rule_collection_group_names[each.key].name
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = each.value.priority

  dynamic "application_rule_collection" {
    for_each = try(each.value.application_rule_collections, {})

    content {
      name     = coalesce(try(application_rule_collection.value.name, null), application_rule_collection.key)
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules

        content {
          name                  = coalesce(try(rule.value.name, null), rule.key)
          description           = try(rule.value.description, null)
          source_addresses      = try(rule.value.source_addresses, null)
          source_ip_groups      = try(rule.value.source_ip_groups, null)
          destination_fqdns     = try(rule.value.destination_fqdns, null)
          destination_fqdn_tags = try(rule.value.destination_fqdn_tags, null)
          web_categories        = try(rule.value.web_categories, null)
          terminate_tls         = try(rule.value.terminate_tls, false)

          dynamic "protocols" {
            for_each = rule.value.protocols

            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = try(each.value.network_rule_collections, {})

    content {
      name     = coalesce(try(network_rule_collection.value.name, null), network_rule_collection.key)
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules

        content {
          name                  = coalesce(try(rule.value.name, null), rule.key)
          description           = try(rule.value.description, null)
          source_addresses      = try(rule.value.source_addresses, null)
          source_ip_groups      = try(rule.value.source_ip_groups, null)
          destination_addresses = try(rule.value.destination_addresses, null)
          destination_ip_groups = try(rule.value.destination_ip_groups, null)
          destination_fqdns     = try(rule.value.destination_fqdns, null)
          destination_ports     = rule.value.destination_ports
          protocols             = rule.value.protocols
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = try(each.value.nat_rule_collections, {})

    content {
      name     = coalesce(try(nat_rule_collection.value.name, null), nat_rule_collection.key)
      priority = nat_rule_collection.value.priority
      action   = try(nat_rule_collection.value.action, "Dnat")

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules

        content {
          name                = coalesce(try(rule.value.name, null), rule.key)
          description         = try(rule.value.description, null)
          source_addresses    = try(rule.value.source_addresses, null)
          source_ip_groups    = try(rule.value.source_ip_groups, null)
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          protocols           = rule.value.protocols
          translated_address  = try(rule.value.translated_address, null)
          translated_fqdn     = try(rule.value.translated_fqdn, null)
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}
