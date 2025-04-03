data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rgrp-weu-gaborka812-webapp"
  location = "West Europe"
}

resource "azurerm_container_app_environment" "appenv" {
  location            = azurerm_resource_group.rg.location
  name                = "app-env-weu-gaborka812"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "containerapp" {
  container_app_environment_id = azurerm_container_app_environment.appenv.id
  name                         = "container-app-weu-gaborka812"
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
      name   = "container-app-weu-gaborka812"

      env {
        name  = "DJANGO_ALLOWED_HOSTS"
        value = "*,${join(",", var.extraAllowedHosts)}"
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

resource "azurerm_virtual_network" "vnet" {
  name                = "example-vn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet" {
  name                 = "example-sn"
  resource_group_name  = azurerm_resource_group.rg.location
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.2.0/24"]
  service_endpoints = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
resource "azurerm_private_dns_zone" "privatednszone" {
  name                = "example.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnslink" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.privatednszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on = [azurerm_subnet.snet]
}

resource "azurerm_postgresql_flexible_server" "djangoserver" {
  name                          = "pfsql-flexible-weu-gaborka812"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "16"
  public_network_access_enabled = false
  private_dns_zone_id           = azurerm_private_dns_zone.privatednszone.id
  delegated_subnet_id           = azurerm_subnet.snet.id
  administrator_login           = "psqladmin"
  administrator_password        = random_password.dbadminpassword.result

  storage_mb   = 32768
  storage_tier = "P4"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  sku_name = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.dnslink]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allowazureservices" {
  name             = "allowazureservices"
  server_id        = azurerm_postgresql_flexible_server.djangoserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_database" "databaseDjango" {
  charset   = "UTF8"
  collation = "en_US.utf8"
  name      = "django-test-db"
  depends_on = [azurerm_postgresql_flexible_server.djangoserver, azurerm_resource_group.rg]
  server_id = azurerm_postgresql_flexible_server.djangoserver.id
}

