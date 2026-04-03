variable "name" {
  type        = string
  description = "Explicit virtual network name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region for the virtual network."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the virtual network."
}

variable "address_space" {
  type        = list(string)
  description = "Address spaces assigned to the virtual network."
}

variable "dns_servers" {
  type        = list(string)
  description = "Optional DNS servers configured at the virtual network level."
  default     = []
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
  default     = "network"
}

variable "attributes" {
  type        = list(string)
  description = "Additional name attributes for the virtual network."
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

variable "subnets" {
  type = map(object({
    name                                          = optional(string)
    purpose                                       = optional(string)
    attributes                                    = optional(list(string), [])
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    service_endpoint_policy_ids                   = optional(list(string), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    delegations = optional(map(object({
      name = optional(string)
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    })), {})
  }))
  description = "Subnet definitions keyed by a logical subnet name."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the virtual network."
  default     = {}
}
