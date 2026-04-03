locals {
  name = coalesce(var.name, module.resource_group_name.name)
  tags = merge(module.tags.tags, module.resource_group_name.tags, var.tags)
}
