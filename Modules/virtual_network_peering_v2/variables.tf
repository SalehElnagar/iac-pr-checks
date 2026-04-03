variable "location" {
  type        = string
  description = "Azure region used for conventions-based naming."
}

variable "namespace" {
  type        = string
  description = "Owning namespace used for naming."
}

variable "environment" {
  type        = string
  description = "Deployment environment used for naming."
}

variable "purpose" {
  type        = string
  description = "Purpose token used by the conventions module."
  default     = "peering"
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

variable "local_alias" {
  type        = string
  description = "Short alias used when generating the local peering name."
  default     = "local"
}

variable "remote_alias" {
  type        = string
  description = "Short alias used when generating the remote peering name."
  default     = "remote"
}

variable "local_peering_name" {
  type        = string
  description = "Explicit local peering name."
  default     = null
}

variable "remote_peering_name" {
  type        = string
  description = "Explicit remote peering name."
  default     = null
}

variable "local_virtual_network_id" {
  type        = string
  description = "Local virtual network resource ID."
}

variable "local_virtual_network_name" {
  type        = string
  description = "Local virtual network name."
}

variable "local_resource_group_name" {
  type        = string
  description = "Resource group containing the local virtual network."
}

variable "remote_virtual_network_id" {
  type        = string
  description = "Remote virtual network resource ID."
}

variable "remote_virtual_network_name" {
  type        = string
  description = "Remote virtual network name."
}

variable "remote_resource_group_name" {
  type        = string
  description = "Resource group containing the remote virtual network."
}

variable "local_allow_virtual_network_access" {
  type        = bool
  description = "Whether the local peering allows virtual network access."
  default     = true
}

variable "local_allow_forwarded_traffic" {
  type        = bool
  description = "Whether the local peering allows forwarded traffic."
  default     = true
}

variable "local_allow_gateway_transit" {
  type        = bool
  description = "Whether the local peering allows gateway transit."
  default     = false
}

variable "local_use_remote_gateways" {
  type        = bool
  description = "Whether the local peering uses remote gateways."
  default     = false
}

variable "remote_allow_virtual_network_access" {
  type        = bool
  description = "Whether the remote peering allows virtual network access."
  default     = true
}

variable "remote_allow_forwarded_traffic" {
  type        = bool
  description = "Whether the remote peering allows forwarded traffic."
  default     = true
}

variable "remote_allow_gateway_transit" {
  type        = bool
  description = "Whether the remote peering allows gateway transit."
  default     = false
}

variable "remote_use_remote_gateways" {
  type        = bool
  description = "Whether the remote peering uses remote gateways."
  default     = false
}
