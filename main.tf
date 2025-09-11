resource "azurerm_resource_group" "logicapp_rg" {
  name     = "logicapp-consumption-rg"
  location = "East US"
}

resource "azurerm_logic_app_workflow" "logicapp" {
  name                = "basic-consumption-logicapp"
  location            = azurerm_resource_group.logicapp_rg.location
  resource_group_name = azurerm_resource_group.logicapp_rg.name

  definition = jsonencode({
    "$schema" = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    "contentVersion" = "1.0.0.0"
    "parameters" = {}
    "triggers" = {
      "manual" = {
        "type" = "Request"
        "kind" = "Http"
        "inputs" = {
          "schema" = {}
        }
      }
    }
    "actions" = {
      "response" = {
        "type" = "Response"
        "inputs" = {
          "statusCode" = 200
          "body" = {
            "message" = "Hello from your Consumption Logic App!"
          }
        }
      }
    }
    "outputs" = {}
  })

  tags = {
    environment = "dev"
  }
}
