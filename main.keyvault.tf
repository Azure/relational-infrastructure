# Create the Key Vaults
module "key_vaults" {
  source   = "Azure/avm-res-keyvault-vault/azurerm"
  version  = "0.10.2"
  for_each = local.key_vaults_to_provision

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
  lock                = each.value.lock

  tenant_id                       = each.value.tenant_id
  sku_name                        = each.value.sku_name
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  public_network_access_enabled   = each.value.public_network_access_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days

  wait_for_rbac_before_key_operations     = each.value.wait_for_rbac_before_key_operations
  wait_for_rbac_before_secret_operations  = each.value.wait_for_rbac_before_secret_operations
  wait_for_rbac_before_contact_operations = each.value.wait_for_rbac_before_contact_operations

  role_assignments  = each.value.role_assignments
  network_acls      = each.value.network_acls
  private_endpoints = each.value.private_endpoints
}
