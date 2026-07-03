

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

resource "azapi_resource" "storage" {
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  name      = var.storage_account_name
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.uami.id
    ]
  }

  body = {
    sku = {
      name = "Standard_LRS"
    }

    kind = "StorageV2"

    properties = {
      minimumTlsVersion        = "TLS1_2"
      allowBlobPublicAccess    = false
      allowSharedKeyAccess     = false
      publicNetworkAccess      = "Enabled"
      supportsHttpsTrafficOnly = true
    }
  }
}

#----------------------------------------------------
# RBAC Permissions for Logic App Managed Identity
#----------------------------------------------------

resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

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

# Optional but recommended for Windows Logic App Standard scenarios
resource "azurerm_role_assignment" "file" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

#----------------------------------------------------
# App Service Plan - Workflow Standard
#----------------------------------------------------

resource "azurerm_service_plan" "plan" {
  name                = "logicapp-ws-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Windows"
  sku_name = "WS1"
}

#----------------------------------------------------
# Logic App Standard using AzAPI
#----------------------------------------------------

resource "azapi_resource" "logicapp" {
  type      = "Microsoft.Web/sites@2023-12-01"
  name      = var.logicapp_name
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.uami.id
    ]
  }

  body = {
    kind = "functionapp,workflowapp"

    properties = {
      serverFarmId = azurerm_service_plan.plan.id

      httpsOnly = true

      siteConfig = {
        appSettings = [
          {
            name  = "FUNCTIONS_WORKER_RUNTIME"
            value = "node"
          },
          {
            name  = "FUNCTIONS_EXTENSION_VERSION"
            value = "~4"
          },
          {
            name  = "AzureFunctionsJobHost__extensionBundle__version"
            value = "[1.*, 2.0.0)"
          },
          {
            name  = "WEBSITE_NODE_DEFAULT_VERSION"
            value = "22"
          },
          {
            name  = "WEBSITE_RUN_FROM_PACKAGE"
            value = "1"
          },
          {
            name  = "APP_KIND"
            value = "workflowApp"
          },
          {
            name  = "WORKFLOWS_TENANT_ID"
            value = data.azurerm_client_config.current.tenant_id
          },

          ##################################################
          # Identity-Based AzureWebJobsStorage Configuration
          ##################################################

          {
            name  = "AzureWebJobsStorage__accountName"
            value = azurerm_storage_account.storage.name
          },
          {
            name  = "AzureWebJobsStorage__credential"
            value = "managedidentity"
          },
          {
            name  = "AzureWebJobsStorage__clientId"
            value = azurerm_user_assigned_identity.uami.client_id
          },
          {
            name  = "AzureWebJobsStorage__blobServiceUri"
            value = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net"
          },
          {
            name  = "AzureWebJobsStorage__queueServiceUri"
            value = "https://${azurerm_storage_account.storage.name}.queue.core.windows.net"
          },
          {
            name  = "AzureWebJobsStorage__tableServiceUri"
            value = "https://${azurerm_storage_account.storage.name}.table.core.windows.net"
          }
        ]
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.storage_account_contributor,
    azurerm_role_assignment.blob,
    azurerm_role_assignment.queue,
    azurerm_role_assignment.table,
    azurerm_role_assignment.file
  ]
}
