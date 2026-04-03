locals {
  name = coalesce(var.name, module.policy_name.name)
  tags = merge(module.tags.tags, module.policy_name.tags, var.tags)
}
