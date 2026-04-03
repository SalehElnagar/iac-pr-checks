variable "name" {
  type        = string
  description = "Explicit diagnostic setting name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region used for conventions-based naming."
}

variable "target_resource_id" {
  type        = string
  description = "Target resource ID for the diagnostic setting."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID that will receive the diagnostics."
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Destination table mode for Log Analytics."
  default     = "Dedicated"
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
  default     = "diagnostics"
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
  description = "Whether to append the mapped environment code to the generated diagnostic setting name."
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

variable "enabled_logs" {
  type = list(object({
    category       = optional(string)
    category_group = optional(string)
  }))
  description = "Enabled log categories or category groups."
  default     = []
}

variable "metrics" {
  type = list(object({
    category = string
    enabled  = optional(bool, true)
  }))
  description = "Enabled metric categories."
  default     = []
}
