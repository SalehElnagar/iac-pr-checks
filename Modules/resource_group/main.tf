resource "azurerm_resource_group" "this" {
  name     = local.name
  location = var.location

  tags = local.tags
}
