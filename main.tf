resource "azurerm_resource_group" "example" {
  name     = "workflow-resources"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "workflownew"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_logic_app_trigger_recurrence" "example" {
  name         = "run-every-day"
  logic_app_id = azurerm_logic_app_workflow.example.id
  frequency    = "Day"
  interval     = 1
}
resource "azurerm_logic_app_action_http" "example" {
  name         = "webhook"
  logic_app_id = azurerm_logic_app_workflow.example.id
  method       = "GET"
  uri          = "http://example.com/some-webhook"
}
