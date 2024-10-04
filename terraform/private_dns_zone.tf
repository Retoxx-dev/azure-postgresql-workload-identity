resource "azurerm_private_dns_zone" "psql" {
  name                = "${replace(local.project_name, "-", "")}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "psql" {
  name                  = "vlink-${local.project_name}"
  private_dns_zone_name = azurerm_private_dns_zone.psql.name
  virtual_network_id    = module.virtual_network.id
  resource_group_name   = azurerm_resource_group.this.name

  tags = local.tags
}
