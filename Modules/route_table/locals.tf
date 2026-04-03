locals {
  name = coalesce(var.name, module.route_table_name.name)
  tags = merge(module.tags.tags, module.route_table_name.tags, var.tags)
}
