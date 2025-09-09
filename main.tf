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
  name                               = "consumptionlogicapp"
  parameters = {
    "$connections" = "{\"visualstudioteamservices\":{\"connectionId\":\"/subscriptions/12486a52-70e3-4ae6-9f94-e6bacd147419/resourceGroups/demonewtest_group/providers/Microsoft.Web/connections/visualstudioteamservices-2\",\"connectionName\":\"visualstudioteamservices-2\",\"id\":\"/subscriptions/12486a52-70e3-4ae6-9f94-e6bacd147419/providers/Microsoft.Web/locations/northcentralus/managedApis/visualstudioteamservices\"}}"
  }
  resource_group_name = "demonewtest_group"
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
        description = "<p class=\"editor-paragraph\">@{triggerBody()}</p>"
        title       = "@{triggerBody()}"
      }
      host = {
        connection = {
          name = "@parameters('$connections')['visualstudioteamservices']['connectionId']"
        }
      }
      method = "patch"
      path   = "/@{encodeURIComponent('demonew')}/_apis/wit/workitems/$@{encodeURIComponent('Issue')}"
      queries = {
        account = "v-taaditya0009"
      }
    }
    runAfter = {}
    type     = "ApiConnection"
  })
  logic_app_id = azurerm_logic_app_workflow.res-0.id
  name         = "Create_a_work_item"
}
