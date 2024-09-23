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
resource "azurerm_application_gateway" "application_gateway" {
  ## REQUIRED CONFIGURATIONS ##
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.autoscale_configuration == null ? var.sku.capacity : null
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_name
    subnet_id = var.gateway_ip_subnet_id
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      path                                = backend_http_settings.value.path
      probe_name                          = backend_http_settings.value.probe_name
      request_timeout                     = backend_http_settings.value.request_timeout
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      dynamic "authentication_certificate" {
        for_each = backend_http_settings.value.authentication_certificate != null ? backend_http_settings.value.authentication_certificate : []
        content {
          name = authentication_certificate.value.name
        }
      }

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining != null ? backend_http_settings.value.connection_draining : []
        content {
          enabled           = connection_draining.value.enabled
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }

  ## PUBLIC FRONTEND IP CONFIGURATIONS
  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_public_ips
    content {
      name                 = frontend_ip_configuration.value.name
      public_ip_address_id = frontend_ip_configuration.value.public_ip_id
    }
  }

  ## PRIVATE FRONTEND IP CONFIGURATIONS
  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_private_ips
    content {
      name                            = frontend_ip_configuration.value.name
      subnet_id                       = frontend_ip_configuration.value.subnet_id
      private_ip_address              = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation   = frontend_ip_configuration.value.private_ip_address_allocation
      private_link_configuration_name = frontend_ip_configuration.value.private_link_configuration_name
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = "${local.frontend_port_name}${frontend_port.value}"
      port = frontend_port.value
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = "${local.frontend_port_name}${http_listener.value.frontend_port}"
      protocol                       = http_listener.value.protocol

      host_name            = http_listener.value.host_name
      host_names           = http_listener.value.host_names
      require_sni          = http_listener.value.require_sni
      ssl_certificate_name = http_listener.value.ssl_certificate_name
      firewall_policy_id   = http_listener.value.firewall_policy_id
      ssl_profile_name     = http_listener.value.ssl_profile_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configurations
        content {
          status_code           = custom_error_configuration.value.status_code
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name               = request_routing_rule.value.name
      rule_type          = request_routing_rule.value.rule_type
      http_listener_name = request_routing_rule.value.http_listener_name
      priority           = request_routing_rule.value.priority

      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
      rewrite_rule_set_name       = request_routing_rule.value.rewrite_rule_set_name
      url_path_map_name           = request_routing_rule.value.url_path_map_name
    }
  }

  waf_configuration {
    enabled                  = var.waf_configuration.enabled
    firewall_mode            = var.waf_configuration.firewall_mode
    rule_set_version         = var.waf_configuration.rule_set_version
    rule_set_type            = var.waf_configuration.rule_set_type
    file_upload_limit_mb     = var.waf_configuration.file_upload_limit_mb
    request_body_check       = var.waf_configuration.request_body_check
    max_request_body_size_kb = var.waf_configuration.max_request_body_size_kb

    dynamic "disabled_rule_group" {
      for_each = var.waf_configuration.disabled_rule_groups
      content {
        rule_group_name = disabled_rule_group.value.rule_group_name
        rules           = disabled_rule_group.value.rules
      }
    }

    dynamic "exclusion" {
      for_each = var.waf_configuration.exclusions
      content {
        match_variable          = exclusion.value.match_variable
        selector_match_operator = exclusion.value.selector_match_operator
        selector                = exclusion.value.selector
      }
    }
  }

  ## OPTIONAL CONFIGURATIONS ##
  enable_http2                      = var.enable_http2
  force_firewall_policy_association = var.force_firewall_policy_association
  firewall_policy_id                = var.firewall_policy_id

  dynamic "trusted_client_certificate" {
    for_each = var.trusted_client_certificates
    content {
      name = trusted_client_certificate.value.name
      data = trusted_client_certificate.value.data
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = trusted_root_certificate.value.data
    }
  }

  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      disabled_protocols   = ssl_policy.value.disabled_protocols
      policy_type          = ssl_policy.value.policy_type
      policy_name          = ssl_policy.value.policy_name
      cipher_suites        = ssl_policy.value.cipher_suites
      min_protocol_version = ssl_policy.value.min_protocol_version
    }
  }

  dynamic "probe" {
    for_each = var.health_probes
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      host                                      = probe.value.host
      port                                      = probe.value.port
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers

      dynamic "match" {
        for_each = probe.value.match != null ? [probe.value.match] : []
        content {
          status_code = match.value.status_code
          body        = match.value.body
        }
      }
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = filebase64("${ssl_certificate.value.data}")
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name  = url_path_map.value.default_backend_http_settings_name
      default_redirect_configuration_name = url_path_map.value.default_redirect_configuration_name
      default_rewrite_rule_set_name       = url_path_map.value.default_rewrite_rule_set_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules
        content {
          name                        = path_rule.value.name
          paths                       = path_rule.value.paths
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          redirect_configuration_name = path_rule.value.redirect_configuration_name
          rewrite_rule_set_name       = path_rule.value.rewrite_rule_set_name
          firewall_policy_id          = path_rule.value.firewall_policy_id
        }
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations
    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_sets
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_rules
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = rewrite_rule.value.conditions
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value.request_header_configurations
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value.response_header_configurations
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value.url != null ? [rewrite_rule.value.url] : []
            content {
              path         = url.value.path
              query_string = url.value.query_string
              components   = url.value.components
              reroute      = url.value.reroute
            }
          }

        }
      }
    }
  }
}
