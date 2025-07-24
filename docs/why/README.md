# Why AzRI?

AzRI models Azure IaC like relational databases, using concise maps to cut code sprawl. It simplifies updates compared to traditional Terraform’s repetitive setups. Built on Azure Verified Modules (AVM) and Azure’s Well-Architected Framework, AzRI ensures scalable, resilient deployments with lock groups for coordinated management.

AzRI deploys 2-3x faster in five scenarios, reducing lines of code (LoC) by 55% on average (25 to 11 LoC per scenario). Fewer LoC means quicker authoring, reviews, and edits, boosting deployment frequency and cutting lead times.

## Efficiency Highlights

- **Code Reduction**: Cuts LoC 55% (24–32 to 8–17 per scenario), streamlining development and maintenance.
- **Comparison**: Traditional Terraform requires more LoC due to repetitive resource declarations, slowing workflows.

### Lines of Code (LoC) Metrics

| Metric | What it Measures | How it's Calculated | AzRI vs. Traditional (Avg) |
|--------|------------------|---------------------|----------------------------|
| **Code Conciseness Metric (CCM)** | Total LoC for infrastructure (excludes comments/whitespace/boilerplate). Lower = better. | Count executable HCL lines; e.g., Multi-Region VMs: AzRI 17, traditional 32. | 11 / 25 |
| **Redundancy Reduction Index (RRI)** | % drop in code volume due to reduced redundancy/references. Higher = better. | ((Traditional LoC - AzRI LoC) / Traditional LoC) * 100; e.g., Multi-Region VMs: 47%. | 55% |

### Scenarios Overview

| Scenario | Description | AzRI Advantage | CCM (AzRI / Traditional) | RRI (%) |
|----------|-------------|---------------|--------------------------|---------|
| **Multi-Region VMs** | 3 Windows VMs across regions with VNets, subnets, HTTP/HTTPS rules, external peering, boot diagnostics, Azure Monitor. | Relational links cut LoC vs. verbose traditional code. | 17 / 32 | 47 |
| **Multi-Sub Storage** | Storage accounts in 2 subscriptions with containers, shares, private endpoints, read-only locks. | Grouping reduces LoC significantly. | 8 / 20 | 60 |
| **Secure Networks** | 2 VNets with subnets, routes, SSH rules from external subnet, peering. | Fluent syntax lowers LoC for clarity. | 9 / 24 | 63 |
| **Role-Based VMs** | 2 VM sets (app/db) with data disks, weekly maintenance, key vaults. | Linked specs lower LoC. | 10 / 18 | 44 |
| **Hybrid Integration** | Azure-external integration with routes/peering, VMs, storage endpoints, locks across subscriptions. | Key-based references shrink LoC. | 11 / 30 | 63 
