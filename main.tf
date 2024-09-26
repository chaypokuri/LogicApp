provider "azurerm" {
  features {}
  subscription_id = "c2bd123a-183f-43d5-bf41-c725494e595a"
  tenant_id       = "3180c264-31bc-4113-8f50-b7393a40457b"
  client_id       = "1a046c02-8c39-4f1d-b30b-93f41a9c6b15"
  client_secret   = "kUz8Q~qwom0J-MM5ZNqexXyUOguygMj5QELdhdl5"
}
# Resource Group
resource "azurerm_resource_group" "this" {
  name     = "rg-this"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = "vnet-this"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for Application Gateway
resource "azurerm_subnet" "this" {
  name                 = "subnet-application-gateway"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "this" {
  name                = "public-ip-this"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "this" {
  name                = "app-gateway-this"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.this.id
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  frontend_port {
    name = "frontend-port-http"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "backend-address-pool"
  }

  http_listener {
    name                           = "http-listener-this"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port-http"
    protocol                       = "Http"
  }
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }
  request_routing_rule {
    name                       = "rule-http"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-this"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "http-settings"
  }
   ssl_policy {
    policy_type         = "Predefined"
    policy_name   = "AppGwSslPolicy20170401S" # Strong security settings
    min_protocol_version = "TLSv1_1"
    cipher_suites = [
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
    ]
  }
}
