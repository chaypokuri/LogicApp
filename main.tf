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
# Required configurations
name                = "my-app-gateway"
resource_group_name = "my-resource-group"
location            = "eastus"
tags = {
  Environment = "Production"
  Team        = "DevOps"
}

# SKU Configuration
sku = {
  name     = "Standard_v2"
  tier     = "Standard"
  capacity = 3
}

# Gateway IP Configuration
gateway_ip_subnet_id = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/virtualNetworks/xxxx/subnets/xxxx"

# Backend Address Pools
backend_address_pools = [
  {
    name         = "backend-pool-1"
    fqdns        = ["example.com"]
    ip_addresses = ["10.0.0.4", "10.0.0.5"]
  }
]

# Backend HTTP Settings
backend_http_settings = [
  {
    name                                = "http-settings-1"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    affinity_cookie_name                = ""
    path                                = "/"
    probe_name                          = "probe1"
    request_timeout                     = 20
    host_name                           = "example.com"
    pick_host_name_from_backend_address = false
    trusted_root_certificate_names      = ["cert1"]
  }
]

# Frontend IPs
frontend_public_ips = [
  {
    name         = "frontend-ip-1"
    public_ip_id = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/publicIPAddresses/xxxx"
  }
]

frontend_private_ips = [
  {
    name                            = "private-frontend-ip"
    subnet_id                       = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/virtualNetworks/xxxx/subnets/xxxx"
    private_ip_address              = "10.0.0.10"
    private_ip_address_allocation   = "Dynamic"
    private_link_configuration_name = null
  }
]

# Frontend Ports
frontend_ports = [80, 443]

# HTTP Listeners
http_listeners = [
  {
    name                           = "listener-1"
    frontend_ip_configuration_name = "frontend-ip-1"
    frontend_port                  = 80
    protocol                       = "Http"
    host_name                      = "example.com"
    host_names                     = ["example.com"]
    require_sni                    = false
    ssl_certificate_name           = null
    firewall_policy_id             = null
    ssl_profile_name               = null
    custom_error_configurations    = []
  }
]

# Request Routing Rules
request_routing_rules = [
  {
    name                         = "rule-1"
    rule_type                    = "Basic"
    http_listener_name           = "listener-1"
    priority                     = 1
    backend_address_pool_name    = "backend-pool-1"
    backend_http_settings_name   = "http-settings-1"
    redirect_configuration_name  = null
    rewrite_rule_set_name        = null
    url_path_map_name            = null
  }
]

# WAF Configuration
waf_configuration = {
  enabled                  = true
  firewall_mode            = "Prevention"
  rule_set_version         = "3.2"
  rule_set_type            = "OWASP"
  file_upload_limit_mb     = 100
  request_body_check       = true
  max_request_body_size_kb = 128
  disabled_rule_groups     = []
  exclusions               = []
}

# Optional configurations
enable_http2                      = true
force_firewall_policy_association = false
firewall_policy_id                = null

# Trusted Client Certificates
trusted_client_certificates = []

# Autoscale Configuration
autoscale_configuration = {
  min_capacity = 2
  max_capacity = 5
}

# SSL Policy
ssl_policy = {
  disabled_protocols   = ["TLSv1_0", "TLSv1_1"]
  policy_type          = "Custom"
  policy_name          = "AppGwSslPolicy"
  cipher_suites        = ["TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
  min_protocol_version = "TLSv1_2"
}

# Health Probes
health_probes = [
  {
    name                  = "probe1"
    protocol              = "Http"
    path                  = "/"
    interval              = 30
    timeout               = 30
    unhealthy_threshold   = 3
    host                  = "example.com"
    port                  = 80
    pick_host_name_from_backend_http_settings = false
    minimum_servers       = 2
    match = {
      status_code = "200-399"
      body        = ""
    }
  }
]

# SSL Certificates
ssl_certificates = [
  {
    name                = "ssl-cert-1"
    data                = "path/to/your/certificate.pfx"
    password            = "cert-password"
    key_vault_secret_id = null
  }
]

# URL Path Maps
url_path_maps = []

# Redirect Configurations
redirect_configurations = []

# Rewrite Rule Sets
rewrite_rule_sets = []
