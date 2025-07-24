# Why AzRI?

**AzRI deploys 2-3x faster, reducing lines of code (LoC) over traditional Terraform by 55% on average.**

Fewer LoC means quicker authoring, reviews, and edits, boosting deployment frequency and cutting lead times.

But don't take our word for it — review the scenarios below to learn how we arrived at these numbers.

## Scenarios Overview

| Scenario | Scenario | AzRI Advantage |
|----------|-------------|---------------|
| [**Multi-Region VMs**](scenario_multi_region_vms.md) | Create two VNets in different regions, each with subnets, custom routes to internet/gateway, security rules denying all inbound except SSH from specific external subnet, and peering between them. Integrate with external cloud network. | AzRI slashes code by 60% (8 vs. 20 LoC) through grouped locks and implicit endpoints, simplifying cross-subscription storage management. Teams save time on maintenance and private link configurations. |
| **Multi-Sub Storage** | Storage accounts in 2 subscriptions with containers, shares, private endpoints, read-only locks. | Grouping reduces LoC significantly. |
| **Secure Networks** | 2 VNets with subnets, routes, SSH rules from external subnet, peering. | Fluent syntax lowers LoC for clarity. |
| **Role-Based VMs** | 2 VM sets (app/db) with data disks, weekly maintenance, key vaults. | Linked specs lower LoC. |
| **Hybrid Integration** | Azure-external integration with routes/peering, VMs, storage endpoints, locks across subscriptions. | Key-based references shrink LoC. |
