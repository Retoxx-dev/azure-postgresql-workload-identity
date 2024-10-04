resource "random_string" "psql_admin_username" {
  length  = 8
  special = false
}

resource "random_password" "psql_admin_password" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "psql-${local.project_name}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  version                = "16"
  administrator_login    = random_string.psql_admin_username.result
  administrator_password = random_password.psql_admin_password.result
  zone                   = "1"

  delegated_subnet_id           = module.virtual_network.subnet_ids["snet-${local.project_name}-postgresql"]
  private_dns_zone_id           = azurerm_private_dns_zone.psql.id
  public_network_access_enabled = false

  storage_mb = 32768

  sku_name = "B_Standard_B1ms"

  authentication {
    active_directory_auth_enabled = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  tags = local.tags
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  server_name         = azurerm_postgresql_flexible_server.this.name
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  principal_name      = local.psql_entra_id_admin_email
  principal_type      = "User"
}
