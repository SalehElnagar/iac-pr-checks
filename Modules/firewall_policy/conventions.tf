module "tags" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/tags?ref=v0.2.0"

  metadata = {
    namespace   = var.namespace
    application = var.application
    environment = var.environment
    additional  = var.tags
  }
}

module "policy_name" {
  source = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "AFWP"
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

module "rule_collection_group_names" {
  for_each = var.rule_collection_groups
  source   = "git::ssh://git@github.com/SalehElnagar/terraform-conventions.git//conventions/modules/resource?ref=v0.2.0"

  naming = {
    prefix               = "AFWRCG"
    location             = var.location
    namespace            = var.namespace
    purpose              = var.purpose
    environment          = var.environment
    environment_instance = var.environment_instance
    attributes = distinct(concat(
      var.attributes,
      length(try(each.value.attributes, [])) > 0 ? each.value.attributes : [each.key]
    ))
  }

  options = {
    delimiter             = "-"
    standardize           = var.standardize_name
    include_environment   = var.include_environment
    use_short_environment = var.use_short_environment
    name_override         = try(each.value.name, null)
  }
}
