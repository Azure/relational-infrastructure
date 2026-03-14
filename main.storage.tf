module "storage_accounts" {
  source   = "Azure/avm-res-storage-storageaccount/azurerm"
  version  = "0.6.7"
  for_each = local.storage_accounts_to_provision

  name                       = each.value.name
  location                   = each.value.location
  resource_group_name        = each.value.resource_group_name
  tags                       = each.value.tags
  access_tier                = each.value.access_tier
  account_tier               = each.value.account_tier
  account_kind               = each.value.account_kind
  account_replication_type   = each.value.account_replication_type
  https_traffic_only_enabled = each.value.https_traffic_only_enabled
  lock                       = each.value.lock
  containers                 = each.value.containers
  shares                     = each.value.shares
  private_endpoints          = each.value.private_endpoints
}
