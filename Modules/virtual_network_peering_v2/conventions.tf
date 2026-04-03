module "local_peering_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "VNP"
    location             = var.location
    namespace            = var.namespace
    purpose              = var.purpose
    environment          = var.environment
    environment_instance = var.environment_instance
    attributes           = [var.local_alias, "to", var.remote_alias]
  }

  options = {
    delimiter             = "-"
    standardize           = var.standardize_name
    include_environment   = var.include_environment
    use_short_environment = var.use_short_environment
    name_override         = var.local_peering_name
  }
}

module "remote_peering_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "VNP"
    location             = var.location
    namespace            = var.namespace
    purpose              = var.purpose
    environment          = var.environment
    environment_instance = var.environment_instance
    attributes           = [var.remote_alias, "to", var.local_alias]
  }

  options = {
    delimiter             = "-"
    standardize           = var.standardize_name
    include_environment   = var.include_environment
    use_short_environment = var.use_short_environment
    name_override         = var.remote_peering_name
  }
}
