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
resource "azurerm_resource_group" "rg" {
  name     = "resource-group"
  location = "Spain Central"
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "snet" {
  name                 = "virtual-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}


module "application_gateway" {
  source              = "aztfm/application-gateway/azurerm"
  version             = ">=2.0.0"
  name                = "application-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "WAF_v2"
  capacity            = 1
  subnet_id           = azurerm_subnet.snet.id
  frontend_ip_configuration = {
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  backend_address_pools = [{
    name         = "backend-address-pool",
    ip_addresses = ["10.0.0.4", "10.0.0.5"]
  }]
  http_listeners = [{
    name                      = "http-listener"
    frontend_ip_configuration = "Public"
    protocol                  = "Http"
    port                      = 80
  }]
  backend_http_settings = [{
    name     = "backend-http-setting-1"
    protocol = "Http"
    port     = 80
  }]
  request_routing_rules = [{
    name                       = "request-routing-rule"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-setting"
  }]
}
  ssl_policy {
   min_protocol_version = "TLSv1_3"
   disabled_protocols   = ["TLSv1_0", "TLSv1_1","TLSv1_2"]
   cipher_suites        = ["TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
  }
}


