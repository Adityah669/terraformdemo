resource "azurerm_resource_group" "example" {
  name     = "workflow-resources"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "workflownew1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_logic_app_trigger_recurrence" "example" {
  name         = "runeveryday"
  logic_app_id = azurerm_logic_app_workflow.example.id
  frequency    = "Minute"
  interval     = 1
}
resource "azurerm_logic_app_action_http" "example" {
  name         = "webhook"
  logic_app_id = azurerm_logic_app_workflow.example.id
  method       = "GET"
  uri          = "https://github.com/Adityah669"
}
