variable "name" {
  type        = string
  description = "Explicit route table name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region for the route table."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the route table."
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
  default     = "routing"
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
  description = "Whether to append the mapped environment code to the generated route table name."
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

variable "disable_bgp_route_propagation" {
  type        = bool
  description = "Whether BGP route propagation is disabled."
  default     = false
}

variable "routes" {
  type = map(object({
    name                   = optional(string)
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "Routes that will be created inside the route table."
  default     = {}

  validation {
    condition = alltrue([
      for route in values(var.routes) :
      route.next_hop_type != "VirtualAppliance" || try(route.next_hop_in_ip_address, null) != null
    ])
    error_message = "Routes using next_hop_type VirtualAppliance must include next_hop_in_ip_address."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets that should be associated with the route table."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the route table."
  default     = {}
}
