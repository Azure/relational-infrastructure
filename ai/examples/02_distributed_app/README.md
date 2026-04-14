# Example 02: Distributed App with DR Mirror

## The Diagram

<!-- Place the whiteboard image here -->
![Architecture Diagram](diagram.png)

## What the Diagram Shows

A hand-drawn whiteboard sketch of a three-tier application with availability zones and a disaster recovery copy:

- **Main VNet** containing three subnets (Web, API, DB) — each with 3 VMs
- **Availability zone distribution**: AZ1 holds 2 VMs per role, AZ2 holds 1 VM per role
- **Port-specific NSG annotations**: "Allow only 443" under the API Subnet, "Allow only SQL" under the DB Subnet
- A dashed **"Peered"** line to a box labeled **"DR Mirror Deployment"**

## How the TFVARS Were Generated

The diagram was given to an AI agent along with the AzRI system prompt. The AI performed an exhaustive visual inventory, then mapped each element to the relational model. The "DR Mirror Deployment" label was a **structural ambiguity** — the AI confirmed with the architect that it meant an exact replica of the primary architecture in a second region before proceeding.

### Diagram element → TFVARS structure

| Diagram Element | TFVARS Structure |
|---|---|
| "Main VNet" box | `networks.main_vnet` |
| Web Subnet column (Web₁, Web₂, Web₃) | `networks.main_vnet.subnets.web` + `virtual_machine_sets.web` |
| API Subnet column (API₁, API₂, API₃) | `networks.main_vnet.subnets.api` + `virtual_machine_sets.api` |
| DB Subnet column (DB₁, DB₂, DB₃) | `networks.main_vnet.subnets.db` + `virtual_machine_sets.db` |
| AZ1 / AZ2 row boundaries | `zones` on each `virtual_machine_sets` entry |
| "Allow only 443" annotation | `network_security_rules.allow_443_to_main_api` + `network_ports.https` |
| "Allow only SQL" annotation | `network_security_rules.allow_sql_to_main_db` + `network_ports.mssql` |
| Dashed "Peered" line | `peered_to` on both VNets (bidirectional) |
| "DR Mirror Deployment" box | Full duplicate: `networks.dr_vnet`, DR VM sets, DR NSGs, DR key vault |

### What the AI inferred

The diagram was explicit about VM counts, availability zones, port restrictions, and the DR relationship. The AI filled in:

- **VNet and subnet CIDRs** — 10.0.0.0/16 for primary, 10.1.0.0/16 for DR to avoid overlap on peering (marked `# REVIEW:`)
- **Two regions** — defaulted to `eastus` and `westus2` (marked `# REVIEW:`)
- **Subscription ID** — placeholder GUID (marked `# REVIEW:`)
- **Key vaults** — one per region, required by `virtual_machine_sets` (marked `# EXPLAIN`)
- **VM images** — defaulted to Windows Server 2022 (marked `# REVIEW:`)
- **SQL port** — interpreted "Allow only SQL" as port 1433 / SQL Server (marked `# REVIEW:`)
- **Deny-all baselines** — created for every subnet with an allow rule, ensuring only the named port gets through

### Traffic flow interpretation

The AI read the port annotations and absence of restriction on the Web Subnet to derive:

- **Any → Web**: unrestricted (no NSG on Web Subnet)
- **Any → API**: port 443 only
- **Any → DB**: SQL port only
- All rules are **mirrored identically** in the DR region

## Output

See [output.tfvars](output.tfvars) for the generated file. Search for `# REVIEW:` to find every value that needs human verification.
