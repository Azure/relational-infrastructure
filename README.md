# Epic on Azure Terraform Module Stack

This repo provides a modular Terraform stack for deploying Epic on Azure, built using Microsoft’s [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) standards. At the foundation, it uses official [AVM resource modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/) to provision core Azure services. On top of that, it layers AVM-aligned pattern modules such as:

- [`epic`](/epic)
- [`infra_map`](/infra_map)
- [`subscription_infra_map`](/subscription_infra_map)
- [`infra_map_vm_set`](/infra_map_vm_set)

These modules define infrastructure using normalized, table-style map variables—enabling consistent, scalable deployments across regions, subscriptions, and workloads.

![Module stack](assets/avmstack.png)

This modular approach supports:

- **Reusability** – Modules are composable and valuable on their own.
- **Maintainability** – Small, focused modules reduce complexity and risk.
- **Shareability** – Only the Epic-specific layer is private; everything else can be reused or published.

## Infrastructure Model

This section describes the foundational infrastructure map that powers the module stack. It defines a normalized, relational model for describing Azure infrastructure in simple, structured terms. Epic-specific modules then layer on a domain-specific map—effectively a relational database of the Azure resources needed to deploy an Epic environment.



## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
