module "tags" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/tags?ref=v0.2.0"

  metadata = {
    namespace   = var.namespace
    application = var.application
    environment = var.environment
    additional  = var.tags
  }
}

module "virtual_network_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "VN"
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

module "subnet_names" {
  for_each = var.subnets
  source   = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "SUB"
    location             = var.location
    namespace            = var.namespace
    purpose              = coalesce(try(each.value.purpose, null), var.purpose)
    environment          = var.environment
    environment_instance = var.environment_instance
    attributes           = try(each.value.attributes, [])
  }

  options = {
    delimiter             = "-"
    standardize           = var.standardize_name
    include_environment   = var.include_environment
    use_short_environment = var.use_short_environment
    name_override         = try(each.value.name, null)
  }
}
