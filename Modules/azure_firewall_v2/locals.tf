locals {
  name           = coalesce(var.name, module.firewall_name.name)
  public_ip_name = coalesce(var.public_ip_name, module.firewall_public_ip_name.name)
  tags           = merge(module.tags.tags, module.firewall_name.tags, module.firewall_public_ip_name.tags, var.tags)
}
