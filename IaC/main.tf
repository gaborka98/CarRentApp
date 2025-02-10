data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rgrp-weu-gaborka812-webapp"
  location = "West Europe"
}

resource "azurerm_service_plan" "webappPlan" {
  name                = "serviceplan-weu-gaborka812-django"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webappName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.webappPlan.id

  app_settings = {
    "DJANGO_ALLOWED_HOST" = "${var.webappName}.azurewebsites.net,${join(",", var.extraAllowedHosts)}"
    "DJANGO_DB_TYPE"      = "postgres"
    "POSTGRES_HOST"       = azurerm_postgresql_server.postgreserver.fqdn
    "POSTGRES_USER"       = azurerm_postgresql_server.postgreserver.administrator_login
    "POSTGRES_PASSWORD"   = azurerm_postgresql_server.postgreserver.administrator_login_password
    "POSTGRES_DB"         = azurerm_postgresql_database.databaseDjango.name
    "AZURE_ACCOUNT_NAME"  = azurerm_storage_account.cdn.name
    "AZURE_ACCOUNT_KEY"   = azurerm_storage_account.cdn.primary_access_key
  }

  site_config {
    always_on = false
    application_stack {
      docker_image_name   = var.dockerimageName
      docker_registry_url = var.dockerRegistryUrl
    }
  }

  depends_on = [
    azurerm_resource_group.rg, azurerm_service_plan.webappPlan, azurerm_postgresql_database.databaseDjango,
    azurerm_storage_account.cdn
  ]
}

resource "azurerm_key_vault" "admin" {
  name                        = "kv-weu-gaborka812-django"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "premium"
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_role_assignment" "appToKv" {
  scope                = azurerm_key_vault.admin.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on = [azurerm_key_vault.admin]
}
resource "azurerm_role_assignment" "ownerToKv" {
  scope                = azurerm_key_vault.admin.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "ea83df21-60f5-4f8c-ab84-09daeb5504a1"
  depends_on = [azurerm_key_vault.admin]
}

resource "random_password" "dbadminpassword" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "dbpassword" {
  key_vault_id = azurerm_key_vault.admin.id
  name         = "ms-sql-admin-password"
  value        = random_password.dbadminpassword.result

  depends_on = [azurerm_role_assignment.appToKv, random_password.dbadminpassword]
}

resource "azurerm_postgresql_server" "postgreserver" {
  location            = azurerm_resource_group.rg.location
  name                = "postgre-server-weu-gaborka812-djangotest"
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "postgreadmin"
  administrator_login_password = random_password.dbadminpassword.result

  sku_name                         = "B_Gen5_1"
  storage_mb                       = 5120
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  backup_retention_days        = 7
  auto_grow_enabled            = false
  geo_redundant_backup_enabled = false

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_postgresql_database" "databaseDjango" {
  charset             = "UTF8"
  collation           = "en_US.utf8"
  name                = "django-test-db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgreserver.name

  depends_on = [azurerm_postgresql_server.postgreserver]
}

# resource "azurerm_mssql_server" "django" {
#   name                         = "mssqlserver-weu-gaborka812-django"
#   resource_group_name          = azurerm_resource_group.rg.name
#   location                     = azurerm_resource_group.rg.location
#   version                      = "12.0"
#   administrator_login          = "azureadmin"
#   administrator_login_password = random_password.dbadminpassword.result
#   minimum_tls_version          = "1.2"
#
#   azuread_administrator {
#     login_username = "gaborka812"
#     object_id      = data.azurerm_client_config.current.object_id
#   }
#
#   depends_on = [azurerm_resource_group.rg, random_password.dbadminpassword]
# }
#
# resource "azurerm_mssql_database" "djangodb" {
#   name         = "mssqldatabase-weu-gaborka812-django"
#   server_id    = azurerm_mssql_server.django.id
#   collation    = "SQL_Latin1_General_CP1_CI_AS"
#   license_type = "LicenseIncluded"
#   sku_name     = "S0"
#   max_size_gb  = 5
#   depends_on = [azurerm_mssql_server.django]
# }

