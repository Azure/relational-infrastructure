This repo provides a modular Terraform stack for deploying Epic on Azure, built using Microsoft’s [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) standards.

At the base, it uses official [AVM resource modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/). On top, it layers AVM-aligned pattern modules like [`avm-ptn-hub-networking`](https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking/azurerm/latest), [`infra_map`](/infra_map), `infra_map_vm_set`, and `subscription_infra_map`. These use normalized, table-style map variables to describe complex infrastructure cleanly and consistently.

- **Reusability** – Every module adds value on its own, across environments.
- **Maintainability** – Smaller modules reduce complexity and blast radius.
- **Shareability** – Only the Epic-specific layer is private; the rest can be published and reused.

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
