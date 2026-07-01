terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

#----------------------------------------------------
# Resource Group
#----------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

#----------------------------------------------------
# User Assigned Managed Identity
#----------------------------------------------------

resource "azurerm_user_assigned_identity" "uami" {
  name                = "uami-logicapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#----------------------------------------------------
# Storage Account
#----------------------------------------------------

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = true
  shared_access_key_enabled = false

  min_tls_version = "TLS1_2"
}

resource "azurerm_storage_share" "content" {
  name               = "logicapp-content"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 100
}

#----------------------------------------------------
# RBAC Permissions
#----------------------------------------------------

resource "azurerm_role_assignment" "blob" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

resource "azurerm_role_assignment" "queue" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

resource "azurerm_role_assignment" "table" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

#----------------------------------------------------
# App Service Plan
#----------------------------------------------------

resource "azurerm_service_plan" "plan" {

  name                = "logicapp-ws-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Windows"
  sku_name = "WS1"
}

#----------------------------------------------------
# Logic App Standard
#----------------------------------------------------

resource "azurerm_logic_app_standard" "logicapp" {

  name                       = var.logicapp_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  storage_account_access_key = false
  app_service_plan_id        = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name


  identity {
    type         = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.uami.id
    ]
  }

  app_settings = {

    FUNCTIONS_WORKER_RUNTIME      = "node"
    FUNCTIONS_EXTENSION_VERSION   = "~4"
    WEBSITE_RUN_FROM_PACKAGE      = "1"

    ##################################################
    # Identity Based Storage Configuration
    ##################################################

    AzureWebJobsStorage__accountName = azurerm_storage_account.storage.name

    AzureWebJobsStorage__credentialType ="managedidentity"

    AzureWebJobsStorage__managedIdentityResourceId = azurerm_user_assigned_identity.uami.id

    AzureWebJobsStorage__blobServiceUri = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net"

    AzureWebJobsStorage__queueServiceUri ="https://${azurerm_storage_account.storage.name}.queue.core.windows.net"

    AzureWebJobsStorage__tableServiceUri ="https://${azurerm_storage_account.storage.name}.table.core.windows.net"
  }

  depends_on = [
    azurerm_role_assignment.blob,
    azurerm_role_assignment.queue,
    azurerm_role_assignment.table
  ]
}
