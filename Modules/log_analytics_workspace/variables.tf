variable "name" {
  type        = string
  description = "Explicit Log Analytics workspace name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region for the workspace."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the workspace."
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
  default     = "monitoring"
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
  description = "Whether to append the mapped environment code to the generated workspace name."
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
  description = "Workspace SKU."
  default     = "PerGB2018"
}

variable "retention_in_days" {
  type        = number
  description = "Retention period in days."
  default     = 30
}

variable "daily_quota_gb" {
  type        = number
  description = "Daily ingestion quota in gigabytes. Leave null for unlimited."
  default     = null
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Whether public ingestion is enabled."
  default     = true
}

variable "internet_query_enabled" {
  type        = bool
  description = "Whether public query access is enabled."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the workspace."
  default     = {}
}
