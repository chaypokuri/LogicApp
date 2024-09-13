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

module "key_vault" {
  source  = "app.terraform.io/BannerHealth/key_vault/azurerm"
  version = "1.0.0"

  for_each = var.key_vaults

  name                            = each.value.name
  resource_group_name             = module.resource_group[each.value.resource_group_key].name
  location                        = var.global_config.location
  sku_name                        = each.value.sku_name
  key_vault_keys                  = each.value.key_vault_keys
  key_vault_secrets               = each.value.key_vault_secrets
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  network_acls                    = each.value.network_acls
  tags                            = merge(var.global_config.mandatory_tags, each.value.tags)
}
