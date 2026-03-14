# Complete Example

This example demonstrates the full relational infrastructure module with all key reference patterns.

## Key Reference Pattern

This module uses a "key reference" pattern where resources reference each other by map keys rather than resource IDs. This enables:

1. **Declarative relationships** - Define connections between resources without knowing their IDs
2. **Validation at plan time** - Terraform validates that all key references exist
3. **Maintainable configurations** - Change a resource's properties without updating references

## Key Reference Types

| Reference Type | Source Variable | Used In |
|---------------|-----------------|---------|
| `location_key_reference` | `var.locations` | Resource groups, networks, storage, key vaults |
| `resource_group_key_reference` | `var.resource_groups` | All resources |
| `lock_groups_key_reference` | `var.lock_groups` | All resources |
| `network_key_reference` | `var.virtual_networks` | Subnets, private endpoints, NICs |
| `subnet_key_reference` | `var.virtual_networks[*].subnets` | Private endpoints, NICs |
| `route_table_key_reference` | `var.route_tables` | Subnets |
| `network_security_group_key_reference` | `var.network_security_groups` | Subnets |
| `security_rules_key_reference` | `var.network_security_rules` | NSGs |
| `private_dns_zone_key_references` | `var.private_dns_zones` | Private endpoints |
| `storage_account_key_reference` | `var.storage_accounts` | Blob containers, file shares |
| `key_vault_key_reference` | `var.key_vaults` | VM sets |
| `image_key_reference` | `var.virtual_machine_images` | VM sets |
| `extensions_by_key_reference` | `var.virtual_machine_extensions` | VM sets |
| `shutdown_schedule_key_reference` | `var.virtual_machine_shutdown_schedules` | VM sets |
| `schedule_key_reference` | `var.maintenance_schedules` | VM sets (maintenance) |

## Usage

```bash
cd examples/complete
terraform init
terraform plan
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Locations                               │
│    eastus ────────────────┬───────────────────────────┐         │
│                           │                           │         │
│    ┌──────────────────────▼────────────────────────┐  │         │
│    │              Resource Groups                   │  │         │
│    │  shared ─┬─ network ─┬─ compute ─┬─ storage   │  │         │
│    └──────────┼───────────┼───────────┼────────────┘  │         │
│               │           │           │               │         │
│    ┌──────────▼───────────▼───────────┼──────────────┼─────────┐│
│    │           Virtual Networks                      │         ││
│    │   hub ◄──────────────────────► spoke_app        │         ││
│    │    │                              │             │         ││
│    │    └── subnets                    └── subnets   │         ││
│    │        firewall                       web ◄─── NSG       ││
│    │        bastion                        app ◄─── NSG       ││
│    │        gateway                        data              ││
│    │                                       private_endpoints  ││
│    └─────────────────────────────────────────────────────────────┘│
│                                                                   │
│    ┌─────────────────────────────────────────────────────────────┐│
│    │              Virtual Machine Sets                           ││
│    │   web_servers ─────┬───── image_key_reference ──► windows_2022    │
│    │       │            ├───── key_vault_key_reference ──► secrets     │
│    │       │            ├───── network_key_reference ──► spoke_app     │
│    │       │            └───── extensions_by_key_reference ──► [...]   │
│    │   app_servers ─────┴───── (same pattern)                    ││
│    └─────────────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────────────┘
```
