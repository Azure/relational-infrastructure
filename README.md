# Epic on Azure Terraform Module Stack

This project offers a modular Terraform framework for deploying Azure IaaS resources. Its design centers on making even private patterns generic, so that as much of the framework as possible is public and reusable. This means that while specialized needs (like Epic-specific deployments) are handled in a private layer, the core components are designed to be flexible and broadly applicable.

## High-Level Design Philosophy

- **Generic Yet Specialized:**  
  By abstracting private patterns into generic components, we ensure that the core modules are reusable across different deployments. The private layer can then extend these modules to meet specialized requirements.

- **Layered Architecture:**  
  - **Public Layers:**  
    These include modules such as:
    - **infra_map_vm_set:** Manages virtual machine sets with high availability.
    - **subscription_infra_map:** Configures resources for individual subscriptions.
    - **infra_map:** Extends resource mapping for multi-subscription environments.
  
  - **Private Layer:**  
    - **epic:** Tailored for specific deployments (like Epic in healthcare) while leveraging the public modules for common functionality.

- **Relational Schema & Modularity:**  
  Resources are defined as maps and objects, establishing clear relationships (e.g., linking VMs to networks). This relational approach mirrors database design, simplifying management and enhancing scalability.

- **Scalability & Security:**  
  The framework supports deployments across multiple subscriptions and regions. It also incorporates best practices for security with private endpoints, network ACLs, and Azure Key Vault integrations.

## Key Concepts

1. **Modularity:**  
   Each module focuses on a specific part of the deployment (e.g., VMs, networks, Key Vaults) so that they can be used independently or combined as needed.

2. **Reusability:**  
   By designing modules with a generic relational schema, we maximize the potential for reuse across different environments—public or private.

3. **Customization:**  
   Users can override defaults and adjust configurations (like VM images, disk settings, or network interfaces) to tailor the deployment to their unique requirements.

## Navigating the Project

### Variables & Configuration

The `variables.tf` files in each module define all configurable inputs. They use a relational schema to ensure consistency and reusability. Key variables include:

- **`virtual_machine_sets`:**  
  Defines VM configurations, including network interfaces, data disks, and image options.

- **`networks`:**  
  Sets up virtual networks and subnets with security rules.

- **`key_vaults`:**  
  Configures Azure Key Vault settings including secrets and private endpoints.

- **`subscriptions`:**  
  Maps subscription-specific configurations for multi-subscription deployments.

### Core Files

- **`main.tf`:**  
  Implements the logic for resource creation using dynamic variable references.

- **`outputs.tf`:**  
  Exposes key outputs (such as resource IDs and names) for use by other modules or higher-level configurations.

### Validation

Input validation blocks ensure that all required fields are provided and that the values (like Azure locations) are valid.

## Examples

### Example 1: Virtual Machine Sets

Defines detailed specifications for deploying VM sets, linking them to networks and storage.

variable "virtual_machine_sets" {
  type = map(object({
    key_vault_name                    = string
    location_name                     = string
    resource_group_name               = string
    subscription_name                 = string
    name                              = string
    include_deployment_prefix_in_name = optional(bool, true)
    tags                              = optional(map(string), {})
    extensions                        = optional(list(string), [])
    os_type                           = optional(string, "Windows")
    enable_boot_diagnostics           = optional(bool, false)

    image = optional(object({
      id = optional(string, null)
      reference = optional(object({
        offer     = string
        publisher = string
        sku       = string
        version   = string
      }), null)
    }), null)

    data_disks = optional(map(object({
      lun                          = number
      caching                      = optional(string, "ReadWrite")
      enable_public_network_access = optional(bool, false)
      image = optional(object({
        copy = optional(object({ resource_id = string }), null)
        import = optional(object({ uri = string, secure = optional(bool, true) }), null)
        platform = optional(object({ image_reference_id = string }), null)
        restore = optional(object({ resource_id = string }), null)
      }), null)
    })), {})

    network_interfaces = map(object({
      network_name                  = string
      subnet_name                   = string
      private_ip                    = optional(string, null)
      private_ip_allocation         = optional(string, "Dynamic")
      enable_accelerated_networking = optional(bool, true)
    }))
  }))
}

### Example 2: Key Vaults

Showcases how to configure Azure Key Vaults, including secrets and network ACLs, in a reusable manner.

variable "key_vaults" {
  type = map(object({
    location_name                     = string
    subscription_name                 = string
    resource_group_name               = string
    name                              = optional(string, null)
    include_deployment_prefix_in_name = optional(bool, true)
    sku_name                          = optional(string, "standard")
    tags                              = optional(map(string), {})
    purge_protection_enabled          = optional(bool, true)
    public_network_access_enabled     = optional(bool, true)

    secrets = optional(map(object({
      name            = string
      content_type    = optional(string, null)
      expiration_date = optional(string, null)
    })), {})
  }))
}

## Getting Started

1. **Review Configuration Files:**  
   Start with the `variables.tf` files to understand the available inputs and how resources are interlinked.

2. **Explore Core Logic:**  
   Check `main.tf` for the logic that builds Azure resources and `outputs.tf` for the information that is exposed.

3. **Customize & Deploy:**  
   Leverage the provided examples to configure your own deployment. Adjust settings in `virtual_machine_sets`, `networks`, and other modules to meet your needs.

4. **Extend with Private Patterns:**  
   For specialized deployments (e.g., Epic on Azure), extend the public modules within your private layer, ensuring that you benefit from both reusability and compliance with specific requirements.

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
