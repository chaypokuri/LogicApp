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
policy "enforce-lapp-vnet-integration" {
  source = "../../policies/azure/enforce-lapp-vnet-integration.sentinel"
  enforcement_level = "advisory"
}



