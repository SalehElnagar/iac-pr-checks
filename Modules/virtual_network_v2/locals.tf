locals {
  name        = coalesce(var.name, module.virtual_network_name.name)
  dns_servers = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags        = merge(module.tags.tags, module.virtual_network_name.tags, var.tags)

  subnet_definitions = {
    for key, subnet in var.subnets :
    key => merge(subnet, {
      resolved_name = module.subnet_names[key].name
    })
  }
}
