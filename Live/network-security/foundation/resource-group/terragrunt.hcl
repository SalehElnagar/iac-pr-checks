include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.module_source_prefix}/resource_group${include.root.locals.module_source_ref_query}"
}

locals {
  foundation = include.root.locals.foundation
}

inputs = {
  location              = include.root.locals.region.location
  namespace             = local.foundation.namespace
  application           = local.foundation.application
  environment           = local.foundation.environment
  environment_instance  = local.foundation.environment_instance
  include_environment   = local.foundation.include_environment
  use_short_environment = local.foundation.use_short_environment
  purpose               = local.foundation.resource_group.purpose
  attributes            = local.foundation.resource_group.attributes
  tags                  = include.root.locals.merged_tags
}
