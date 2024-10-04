resource "azurerm_resource_group" "this" {
  name     = "rg-${local.project_name}"
  location = local.location
  tags     = local.tags
}
