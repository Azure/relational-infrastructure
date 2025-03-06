locals {
  key_vault_resource_ids = {
    for name, kv in module.key_vaults : name => kv.resource_id
  }
}