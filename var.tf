variable "subscription_id" {}

variable "resource_group_name" {
  default = "rg-logicapp-prod"
}

variable "location" {
  default = "East US"
}

variable "logicapp_name" {
  default = "logicapp-standard-mi"
}

variable "storage_account_name" {}
