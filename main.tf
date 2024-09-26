provider "azurerm" {
  features {}
}
 
# Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "East US"
}
 
# Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}
 
# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
# Network Security Group for AKS Subnet (Optional)
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}
 
# Attach NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
 
# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aksdns"
 
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }
 
  identity {
    type = "SystemAssigned"
  }
 
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
    dns_service_ip    = "10.0.2.10"
    service_cidr      = "10.0.2.0/24"
    docker_bridge_cidr = "172.17.0.1/16"
  }
 
  role_based_access_control {
    enabled = true
  }
 
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id  = azurerm_log_analytics_workspace.example.id
    }
  }
 
  tags = {
    environment = "Development"
  }
}
 
# Log Analytics Workspace (Optional)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "aks-log-workspace"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
}
 
# Output the AKS cluster details
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}
 
output "kubernetes_cluster_api_url" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
}
 
output "kubernetes_cluster_kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}
