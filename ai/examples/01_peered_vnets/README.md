# Example: Two Peered VNets with Role-Based VMs

## The Diagram

![Hand-drawn architecture diagram](crude_network.png)

A hand-drawn sketch on paper. No tooling, no structured format — just boxes, labels, and arrows.

## What I Saw

Reading the diagram left to right, top to bottom:

1. **An outer box labeled "Resource Group - App01"** — everything lives in a single resource group.
2. **AppVNet (10.100.0.0/16)** — the left VNet, explicitly labeled with its CIDR range, containing two subnets:
   - **Web Subnet** with 3 VMs: Web 1, Web 2, Web 3
   - **API Subnet** with 3 VMs: API 1, API 2, API 3
3. **DB VNet (10.200.0.0/16)** — the right VNet, also labeled with its CIDR, containing:
   - **DB Subnet** with 3 VMs: DB 1, DB 2, DB 3
4. **A dashed line labeled "Peered"** between the two VNets.
5. **Two NSG annotations:**
   - "NSG Can Access" arrow from **Web Subnet → DB Subnet**
   - "NSG Can Access" arrow from **API Subnet → DB Subnet**

## How I Translated It

### Step 1: Identify the relational tables needed

From the diagram, I identified which AzRI tables were needed:

| Diagram Element | AzRI Table | Key(s) |
|----------------|------------|--------|
| "Resource Group - App01" | `resource_groups` | `app01` |
| AppVNet, DB VNet | `networks` | `app_vnet`, `db_vnet` |
| Web Subnet, API Subnet, DB Subnet | `networks.*.subnets` | `web`, `api`, `db` |
| Web 1-3, API 1-3, DB 1-3 | `virtual_machine_sets` | `web`, `api`, `db` |
| "Peered" line | `networks.*.peered_to` | bidirectional references |
| "NSG Can Access" arrows | `network_security_rules` | `allow_web_to_db`, `allow_api_to_db` |

### Step 2: Establish what's explicit vs. what's missing

**Explicit in the diagram:**
- Resource group name: "App01"
- VNet names and CIDRs: AppVNet (10.100.0.0/16), DB VNet (10.200.0.0/16)
- Subnet names: Web Subnet, API Subnet, DB Subnet
- VM counts: 3 per role (I can count the boxes)
- Peering between the two VNets
- NSG direction: Web→DB and API→DB

**NOT in the diagram (had to guess or leave for review):**
- Azure region — no region label anywhere. Defaulted to `eastus`.
- Subscription — no subscription boundary drawn. Modeled as one.
- Subnet CIDRs — only VNet-level CIDRs are shown. Carved /24s from each.
- NSG specifics — "Can Access" doesn't specify ports or protocols. Allowed all traffic.
- VM specs — no SKU, OS, or disk size mentioned. Used reasonable defaults.
- Key Vault — required by AzRI for VM sets but not drawn anywhere.

### Step 3: Model the relationships

AzRI uses foreign keys to express relationships. Here's how the diagram's arrows became key references:

**Peering** — The dashed "Peered" line became bidirectional `peered_to` lists:
```hcl
# AppVNet peers to DB VNet
app_vnet = {
  peered_to = ["db_vnet"]
  ...
}

# DB VNet peers back to AppVNet
db_vnet = {
  peered_to = ["app_vnet"]
  ...
}
```

> AzRI peering is one-way per entry. For two-way traffic (which the NSG arrows require), both sides must declare the peering.

**NSG Rules** — The "Can Access" arrows became allow rules with a deny-all baseline:
```hcl
# First: deny everything inbound to DB
deny_all_inbound_to_db = {
  deny = { in = { to = { subnet = { network_name = "db_vnet", subnet_name = "db" } } } }
}

# Then: allow specifically from web
allow_web_to_db = {
  allow = {
    in = {
      from = { subnet = { network_name = "app_vnet", subnet_name = "web" } }
      to   = { subnet = { network_name = "db_vnet",  subnet_name = "db"  } }
    }
  }
}
```

> The order that security rules appear in a subnet's `security_rules` list determines their priority. Deny-all goes first (highest priority number), then specific allows override it.

**VM placement** — Each VM set's `network_interfaces` section is the foreign key that places VMs into subnets:
```hcl
web = {
  network_interfaces = {
    primary = {
      network_name = "app_vnet"  # 🔗 Links to networks
      subnet_name  = "web"       # 🔗 Links to networks.app_vnet.subnets
    }
  }
}
```

### Step 4: Handle what the diagram doesn't say

Every gap became either a `# REVIEW:` comment (for leaf values the user should check) or a `# EXPLAIN` comment (for structural decisions I made on their behalf):

- **Subnet CIDRs**: `10.100.0.0/24`, `10.100.1.0/24`, `10.200.0.0/24` — carved sequentially from each VNet's /16 space. Marked `# REVIEW`.
- **VM SKUs**: Used `Standard_D4as_v5` for web/api (general purpose) and `Standard_E4as_v5` for db (memory-optimized). Marked `# REVIEW`.
- **Key Vault**: Created one shared key vault since the diagram doesn't mention secrets management, but AzRI requires it for VM sets. Explained with `# EXPLAIN`.
- **DB Data Disks**: Left as a commented-out suggestion since database VMs almost certainly need data disks, but the diagram is silent. Explained with `# EXPLAIN`.

## The Output

See [app01.tfvars](../app01.tfvars) for the complete generated file.

## What I Learned

1. **Hand-drawn CIDR labels translate directly.** The architect wrote "10.100.0.0/16" on the VNet — that went straight into `address_space`. No interpretation needed.
2. **"Can Access" is ambiguous by nature.** In a whiteboard session, this is where an architect would say "SQL only" or "HTTPS only." Without that context, I kept it open and flagged it.
3. **The relational model makes peering trivial.** Two lines of `peered_to` replaced what would be ~30 lines of raw `azurerm_virtual_network_peering` resources in traditional Terraform.
4. **Implicit resources (Key Vault) are the hardest part.** The diagram shows what the architect is *thinking about*. AzRI requires things the architect *takes for granted*. That's where `# EXPLAIN` earns its keep.
