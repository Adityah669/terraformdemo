resource "azurerm_resource_group" "rg" {
  name     = "logicapp-rg"
  location = "East US"
}

resource "azurerm_logic_app_workflow" "logicapp" {
  name                = "send-email-logicapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  definition = 
    "$schema" = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    "actions" = {
      "Send_email" = {
        "inputs" = {
          "body" = {
            "To"      = "v-taaditya@Microsoft.com"
            "Subject" = "Automated Email"
            "Body"    = "This is a test email from Logic App."
          }
          "host" = {
            "connection" = {
              "name" = "@parameters('$connections')['office365']['connectionId']"
            }
          }
          "method" = "post"
          "path"   = "/v2/Mail"
        }
        "runAfter" = {}
        "type"     = "ApiConnection"
      }
    }
    "triggers" = {
      "Recurrence" = {
        "recurrence" = {
          "frequency" = "Minute"
          "interval"  = 1
        }
        "type" = "Recurrence"
      }
    }
    "parameters" = {
      "$connections" = {
        "value" = {
          "office365" = {
            "connectionId" = "<your_connection_id>"
            "connectionName" = "office365"
            "id" = "/subscriptions/12486a52-70e3-4ae6-9f94-e6bacd147419/resourceGroups/demonewtest_group/providers/Microsoft.Web/connections/office365-1"
          }
        }
      }
    }

  parameters = {}
}
