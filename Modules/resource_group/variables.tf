variable "name" {
  type        = string
  description = "Explicit resource group name. When null, the shared conventions module generates the name."
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region where the resource group will be created."
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
  default     = "foundation"
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
  description = "Whether to append the mapped environment code to the generated resource group name."
  default     = true
}

variable "use_short_environment" {
  type        = bool
  description = "Whether to use the short environment mapping."
  default     = true
}

variable "standardize_name" {
  type        = bool
  description = "Whether to standardize the generated resource group name according to the conventions module."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the resource group."
  default     = {}
}
