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
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
 
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.254.0.0/16"]
}
 
resource "azurerm_subnet" "example" {
  name                 = "example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.254.0.0/24"]
}
 
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}
 
resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
 
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
 
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.example.id
  }
 
  frontend_port {
    name = "ex-feport"
    port = 80
  }
 
  frontend_ip_configuration {
    name                 = "ex-frontend_ip_configuration"
    public_ip_address_id = azurerm_public_ip.example.id
  }
 
  backend_address_pool {
    name = "ex-backend_address_pool"
  }
 
  backend_http_settings {
    name                  = "ex-http_setting"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
 
  http_listener {
    name                           = "ex-listener_name"
    frontend_ip_configuration_name = "ex-frontend_ip_configuration"
    frontend_port_name             = "ex-frontend_port"
    protocol                       = "Http"
  }
 
  request_routing_rule {
    name                       = "ex-request_routing_rule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "ex-listener_name"
    backend_address_pool_name  = "ex-backend_address_pool"
    backend_http_settings_name = "ex-http_setting_name"
  }
  ssl_policy {
   min_protocol_version = "TLSv1_2"
  }
}


