variable "name" {
  type        = string
  description = "Explicit firewall policy name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region for the firewall policy."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the firewall policy."
}

variable "namespace" {
  type        = string
  description = "Owning namespace used for naming and tagging."
}

variable "application" {
  type        = string
  description = "Application or platform identifier used for tag generation."
}

variable "environment" {
  type        = string
  description = "Deployment environment used for naming and tagging."
}

variable "purpose" {
  type        = string
  description = "Purpose token used by the conventions module."
  default     = "firewall-policy"
}

variable "attributes" {
  type        = list(string)
  description = "Additional name attributes."
  default     = []
}

variable "environment_instance" {
  type        = number
  description = "Optional environment instance number."
  default     = 0
}

variable "include_environment" {
  type        = bool
  description = "Whether to append the mapped environment code to generated names."
  default     = true
}

variable "use_short_environment" {
  type        = bool
  description = "Whether to use the short environment mapping."
  default     = true
}

variable "standardize_name" {
  type        = bool
  description = "Whether to standardize the generated resource name according to the conventions module."
  default     = true
}

variable "sku" {
  type        = string
  description = "Firewall policy SKU."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.sku)
    error_message = "firewall policy sku must be Standard or Premium."
  }
}

variable "base_policy_id" {
  type        = string
  description = "Optional base policy ID."
  default     = null
}

variable "threat_intelligence_mode" {
  type        = string
  description = "Threat intelligence mode for the policy."
  default     = "Alert"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.threat_intelligence_mode)
    error_message = "threat_intelligence_mode must be Alert, Deny, or Off."
  }
}

variable "dns" {
  type = object({
    proxy_enabled = optional(bool, false)
    servers       = optional(list(string), [])
  })
  description = "Optional DNS settings for the firewall policy."
  default     = null
}

variable "rule_collection_groups" {
  type = map(object({
    name       = optional(string)
    priority   = number
    attributes = optional(list(string), [])
    application_rule_collections = optional(map(object({
      name     = optional(string)
      priority = number
      action   = string
      rules = map(object({
        name                  = optional(string)
        description           = optional(string)
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_fqdn_tags = optional(list(string), [])
        web_categories        = optional(list(string), [])
        terminate_tls         = optional(bool, false)
        protocols = list(object({
          type = string
          port = number
        }))
      }))
    })), {})
    network_rule_collections = optional(map(object({
      name     = optional(string)
      priority = number
      action   = string
      rules = map(object({
        name                  = optional(string)
        description           = optional(string)
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_addresses = optional(list(string), [])
        destination_ip_groups = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_ports     = list(string)
        protocols             = list(string)
      }))
    })), {})
    nat_rule_collections = optional(map(object({
      name     = optional(string)
      priority = number
      action   = optional(string, "Dnat")
      rules = map(object({
        name                = optional(string)
        description         = optional(string)
        source_addresses    = optional(list(string), [])
        source_ip_groups    = optional(list(string), [])
        destination_address = string
        destination_ports   = list(string)
        protocols           = list(string)
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = string
      }))
    })), {})
  }))
  description = "Firewall policy rule collection groups keyed by a logical group name."
  default     = {}

  validation {
    condition = alltrue(flatten([
      for group in values(var.rule_collection_groups) : [
        for nat_collection in values(try(group.nat_rule_collections, {})) : alltrue([
          for rule in values(nat_collection.rules) :
          try(rule.translated_address, null) != null || try(rule.translated_fqdn, null) != null
        ])
      ]
    ]))
    error_message = "Each NAT rule must set either translated_address or translated_fqdn."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the firewall policy."
  default     = {}
}
