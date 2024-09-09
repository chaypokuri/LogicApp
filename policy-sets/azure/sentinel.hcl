#------------------------------------------------------------------------------
# Sentinel Modules (function imports)
#------------------------------------------------------------------------------
module "tfplan-functions" {
  source = "../../functions/tfplan-functions.sentinel"
}

module "azure-functions" {
  source = "../../functions/azure-functions.sentinel"
}

#------------------------------------------------------------------------------
# Sentinel Policies
#------------------------------------------------------------------------------
policy "enforce-required-tags" {
  source            = "../../policies/azure/enforce-required-tags.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-vm-size" {
  source            = "../../policies/azure/restrict-vm-size.sentinel"
  enforcement_level = "advisory"
}

policy "enforce-key-vault-recovery" {
  source = "../../policies/azure/enforce-key-vault-recovery.sentinel"
  enforcement_level = "advisory"
}



