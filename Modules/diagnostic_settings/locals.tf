locals {
  name = coalesce(var.name, module.diagnostic_setting_name.name)
}
