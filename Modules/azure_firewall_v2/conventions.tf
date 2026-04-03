module "tags" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/tags?ref=v0.2.0"

  metadata = {
    namespace   = var.namespace
    application = var.application
    environment = var.environment
    additional  = var.tags
  }
}

module "firewall_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "AFW"
    location             = var.location
    namespace            = var.namespace
    purpose              = var.purpose
    environment          = var.environment
    environment_instance = var.environment_instance
    attributes           = var.attributes
  }

  options = {
    delimiter             = "-"
    standardize           = var.standardize_name
    include_environment   = var.include_environment
    use_short_environment = var.use_short_environment
  }

  tags = {
    include_generated = true
    additional        = var.tags
  }
}

module "firewall_public_ip_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "PIP"
    location             = var.location
    namespace            = var.namespace
    purpose              = var.public_ip_purpose
    environment          = var.environment
    environment_instance = var.environment_instance
    attributes           = var.public_ip_attributes
  }

  options = {
    delimiter             = "-"
    standardize           = var.standardize_name
    include_environment   = var.include_environment
    use_short_environment = var.use_short_environment
  }

  tags = {
    include_generated = true
    additional        = var.tags
  }
}
