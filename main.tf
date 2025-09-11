
resource "azurerm_resource_group" "example" {
  name     = "logicapp-consumption-rg"
  location = "East US"
}

resource "azurerm_template_deployment" "logicapp" {
  name                = "logicapp-deployment"
  resource_group_name = azurerm_resource_group.example.name
  deployment_mode     = "Incremental"

  template_body = 
    "$schema" = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
    "contentVersion" = "1.0.0.0"
    "resources" = [
      {
        "type" = "Microsoft.Logic/workflows"
        "apiVersion" = "2019-05-01"
        "name" = "basic-consumption-logicapp"
        "location" = azurerm_resource_group.example.location
        "properties" = {
          "definition" = {
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
          }
          "state" = "Enabled"
        }
      }
    ]
  })

  parameters = {}
}
