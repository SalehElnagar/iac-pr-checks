locals {
  name = coalesce(var.name, module.workspace_name.name)
  tags = merge(module.tags.tags, module.workspace_name.tags, var.tags)
}
