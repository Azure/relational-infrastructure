# Why AzRI?

**AzRI deploys 2-3x faster, reducing lines of code (LoC) over traditional Terraform by 55% on average.**

Fewer LoC means quicker authoring, reviews, and edits, boosting deployment frequency and cutting lead times.

But don't take our word for it — review the scenarios below to learn how we arrived at these numbers.

## Scenarios Overview

| Scenario | Scenario | AzRI Advantage |
|----------|-------------|---------------|
| [**Multi-Region VMs**](scenario_multi_region_vms.md) | Create two VNets in different regions, each with subnets, custom routes to internet/gateway, security rules denying all inbound except SSH from specific external subnet, and peering between them. Integrate with external cloud network. | AzRI reduces code by 47% (17 vs. 32 LoC), enabling faster multi-region setups with relational links minimizing manual references. This cuts deployment time and error risks in scaling VMs across zones. |
| [**Multi-Sub Storage**](scenario_multi_sub_storage.md) | Set up storage accounts in two subscriptions (production, non-production), each with blob containers and file shares, private endpoints on a dedicated subnet, and lock groups for read-only protection during maintenance. Includes hot access tier and ZRS replication. | AzRI slashes code by 60% (8 vs. 20 LoC) through grouped locks and implicit endpoints, simplifying cross-subscription storage management. Teams save time on maintenance and private link configurations. |
| [**Secure Networks**](scenario_secure_networks.md) | Create two VNets in different regions, each with subnets, custom routes to internet/gateway, security rules denying all inbound except SSH from specific external subnet, and peering between them. Integrate with external cloud network. | With 63% fewer lines (9 vs. 24 LoC), AzRI's fluent syntax streamlines rules, routes, and peerings, reducing complexity in secure topologies. This accelerates network changes without scattered associations. |
| [**Role-Based VMs**](scenario_role_based_vms.md) | Deploy two VM sets (app and db) in one resource group, each with 2 VMs, custom data disks (one empty, one from snapshot), maintenance schedules for weekly updates, and key vault integration for secrets. | AzRI condenses code by 44% (10 vs. 18 LoC) via linked specs for VM sets, disks, and maintenance, easing role-based deployments. It minimizes repetition in attachments and schedules for quicker iterations. |
| [**Hybrid Integration**](scenario_hybrid_integration.md) | Integrate Azure with external networks: VM set in Azure connected to external subnets via routes/peering, storage with private endpoints, all under lock groups for production lockdown, across two subscriptions. | AzRI achieves 63% code reduction (11 vs. 30 LoC) with key-based external refs and inherited locks, simplifying hybrid setups across subscriptions. This lowers overhead in routes, peering, and resource protection. |
