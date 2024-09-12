provider "azurerm" {
  features {}
  subscription_id = "c2bd123a-183f-43d5-bf41-c725494e595a"
  tenant_id       = "3180c264-31bc-4113-8f50-b7393a40457b"
  client_id       = "1a046c02-8c39-4f1d-b30b-93f41a9c6b15"
  client_secret   = "kUz8Q~qwom0J-MM5ZNqexXyUOguygMj5QELdhdl5"
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
resource "azurerm_logic_app_standard" "example" {
  name                       = "test-azure-functions"
  resource_group_name = "test-rg"
  location            = "east us"
  storage_account_name       = "teststorageaccount001"
  storage_account_access_key = "BjYCZEHX2OCqz/HWJdWp4rHfpLIAMJt0adLxzQnpItXCSyKwArG8iCgFfVNW/6pgabrtlniTcEaK+AStF5N8xQ=="
  app_service_plan_id     = "/subscriptions/c2bd123a-183f-43d5-bf41-c725494e595a/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-asp"
  virtual_network_subnet_id = "/subscriptions/c2bd123a-183f-43d5-bf41-c725494e595a/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-rg/subnets/test-subnet"
  site_config {  
  }
}
