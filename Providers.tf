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
  client_id       = "4df05d97-7fd0-40fe-bbbf-fc0f0463a62c"
  client_secret   = var.client_secret
  tenant_id       = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  subscription_id = "12486a52-70e3-4ae6-9f94-e6bacd147419"
}
