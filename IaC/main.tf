data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rgrp${local.resourceNamePostfix}"
  location = "West Europe"
}

resource "azurerm_container_app_environment" "appenv" {
  location            = azurerm_resource_group.rg.location
  name                = "django-appenv${local.resourceNamePostfix}"
  resource_group_name = azurerm_resource_group.rg.name
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 1
  }
}

resource "azurerm_container_app" "containerapp" {
  container_app_environment_id = azurerm_container_app_environment.appenv.id
  name                         = "${var.webappName}${local.resourceNamePostfix}"
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  secret {
    name  = "postgre-db-password"
    value = random_password.dbadminpassword.result
  }
  secret {
    name  = "admin-password"
    value = random_password.djangoadminpassword.result
  }

  ingress {
    target_port      = 8000
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {

    container {
      cpu   = 0.25
      image = var.dockerimageName

      memory = "0.5Gi"
      name   = var.webappName

      env {
        name  = "DJANGO_ALLOWED_HOSTS"
        value = ".azurecontainerapps.io"
      }

      env {
        name  = "DJANGO_ALLOWED_HOSTS"
        value = "https://*.azurecontainerapps.io"
      }
      env {
        name  = "DJANGO_DB_TYPE"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_HOST"
        value = azurerm_postgresql_flexible_server.djangoserver.fqdn
      }
      env {
        name  = "POSTGRES_USER"
        value = azurerm_postgresql_flexible_server.djangoserver.administrator_login
      }
      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgre-db-password"
      }
      env {
        name  = "POSTGRES_DB"
        value = azurerm_postgresql_flexible_server_database.databaseDjango.name
      }

      env {
        name  = "DJANGO_SUPERUSER_EMAIL"
        value = "gaborka98@freemail.hu"
      }

      env {
        name  = "DJANGO_SUPERUSER_USERNAME"
        value = "gaborka98"
      }

      env {
        name        = "DJANGO_SUPERUSER_PASSWORD"
        secret_name = "admin-password"
      }

      env {
        name  = "DJANGO_SECRET_KEY"
        value = random_password.djangosecretkey.result
      }

    }
  }
  depends_on = [azurerm_postgresql_flexible_server_database.databaseDjango]
}

resource "random_password" "dbadminpassword" {
  length  = 16
  special = true
}

resource "random_password" "djangoadminpassword" {
  length  = 16
  special = true
}

resource "random_password" "djangosecretkey" {
  length  = 64
  special = true
  numeric = true
  lower   = true
  upper   = true
}

resource "azurerm_postgresql_flexible_server" "djangoserver" {
  name                          = "django-pfsql${local.resourceNamePostfix}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "16"
  public_network_access_enabled = true
  administrator_login           = "psqladmin"
  administrator_password        = random_password.dbadminpassword.result

  storage_mb   = 32768
  storage_tier = "P4"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  sku_name = "B_Standard_B1ms"

  authentication {
    active_directory_auth_enabled = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
}

resource "azurerm_postgresql_flexible_server_database" "databaseDjango" {
  charset   = "UTF8"
  collation = "en_US.utf8"
  name      = "django-test-db"
  depends_on = [azurerm_postgresql_flexible_server.djangoserver, azurerm_resource_group.rg]
  server_id = azurerm_postgresql_flexible_server.djangoserver.id
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "example" {
  server_name         = azurerm_postgresql_flexible_server.djangoserver.name
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = "ea83df21-60f5-4f8c-ab84-09daeb5504a1"
  principal_name      = "gaborka812_gmail.com#EXT#@gaborka812.onmicrosoft.com"
  principal_type      = "User"

  depends_on = [azurerm_postgresql_flexible_server.djangoserver]
}
