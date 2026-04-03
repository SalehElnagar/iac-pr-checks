module "tags" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/tags?ref=v0.2.0"

  metadata = {
    namespace   = var.namespace
    application = var.application
    environment = var.environment
    additional  = try(var.tags, {})
  }
}

module "vm_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix      = "vm"
    location    = var.location
    namespace   = var.namespace
    purpose     = var.virtual_machine_purpose
    attributes  = var.attributes
    environment = var.environment
  }

  options = {
    delimiter           = "-"
    standardize         = true
    include_environment = true
  }

  tags = {
    include_generated = true
    additional        = try(var.tags, {})
  }
}

