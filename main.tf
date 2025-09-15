terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.40.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_logic_app_workflow" "res-0" {
  enabled                            = true
  integration_service_environment_id = ""
  location                           = "northcentralus"
  logic_app_integration_account_id   = ""
  name                               = "consumptionnewlogicapp"
  parameters = {
    "$connections" = "{\"office365\":{\"connectionId\":\"/subscriptions/12486a52-70e3-4ae6-9f94-e6bacd147419/resourceGroups/demonewtest_group/providers/Microsoft.Web/connections/office365-1\",\"connectionName\":\"office365-1\",\"id\":\"/subscriptions/12486a52-70e3-4ae6-9f94-e6bacd147419/providers/Microsoft.Web/locations/northcentralus/managedApis/office365\"}}"
  }
  resource_group_name = "demonewtestgroup"
  tags                = {}
  workflow_parameters = {
    "$connections" = "{\"defaultValue\":{},\"type\":\"Object\"}"
  }
  workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"
  access_control {
    trigger {
      allowed_caller_ip_address_range = []
      open_authentication_policy {
        name = "AzureADLifecycleWorkflowsAuthPolicyV2App"
        claim {
          name  = "aud"
          value = "b719adf9-5deb-45c6-bb44-9c7395db7f75"
        }
        claim {
          name  = "iss"
          value = "https://login.microsoftonline.com/16b3c013-d300-468d-ac64-7eda0820b6d3/v2.0"
        }
      }
    }
  }
  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }
}
resource "azurerm_logic_app_action_custom" "res-1" {
  body = jsonencode({
    inputs = {
      body = {
        Body       = "<p class=\"editor-paragraph\">Test</p>"
        Importance = "Normal"
        Subject    = "Test"
        To         = "v-taaditya@microsoft.com"
      }
      host = {
        connection = {
          name = "@parameters('$connections')['office365']['connectionId']"
        }
      }
      method = "post"
      path   = "/v2/Mail"
    }
    runAfter = {}
    type     = "ApiConnection"
  })
  logic_app_id = azurerm_logic_app_workflow.res-0.id
  name         = "Send_an_email_(V2)"
}
