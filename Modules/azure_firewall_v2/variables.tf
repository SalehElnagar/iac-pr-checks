variable "name" {
  type        = string
  description = "Explicit firewall name. When null, the shared conventions module generates the name."
  default     = null
}

variable "public_ip_name" {
  type        = string
  description = "Explicit public IP name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region for the firewall."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the firewall and public IP."
}

variable "subnet_id" {
  type        = string
  description = "AzureFirewallSubnet resource ID."
}

variable "firewall_policy_id" {
  type        = string
  description = "Firewall policy ID attached to the firewall."
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
  default     = "firewall"
}

variable "attributes" {
  type        = list(string)
  description = "Additional name attributes for the firewall."
  default     = []
}

variable "public_ip_purpose" {
  type        = string
  description = "Purpose token used when generating the public IP name."
  default     = "firewall"
}

variable "public_ip_attributes" {
  type        = list(string)
  description = "Additional name attributes for the public IP."
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

variable "sku_tier" {
  type        = string
  description = "Firewall SKU tier."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Standard or Premium."
  }
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the firewall."
  default     = null
}

variable "public_ip_zones" {
  type        = list(string)
  description = "Availability zones for the firewall public IP."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the firewall and public IP."
  default     = {}
}
