# Terraform-Azure-AKS

[![Lint Status](https://github.com/tothenew/terraform-azure-aks/workflows/Lint/badge.svg)](https://github.com/tothenew/terraform-azure-aks/actions)
[![LICENSE](https://img.shields.io/github/license/tothenew/terraform-azure-aks)](https://github.com/tothenew/terraform-azure-aks/blob/master/LICENSE)


Terraform module to deploy an aks cluster at azure
The following content needed to be created and managed:

Introduction
Explaination of files
Intended users
Resource created and managed by this code
Example Usages

## Example usage

- Creating a cluster containing usage nodepool

```hcl
location = "eastus2"
resource_group = "Resource_group"
prefix = "new_kubernetes"
node_count = 1
auto_scaling_default_node = false
node_min_count = null
node_max_count = null
default_node_vm_size = "Standard_DS2_v2"
create_additional_node_pool = false 

if "enable_auto_scaling" is "true" then pass values in "min_count" and "max_count".
if "create_additional_node_pool" is "true" only then "additional_node_pool" will get created.

additional_node_pools = {
  "pool1" = {
	vm_size = "Standard_DS2_v2"
    os_disk_size_gb = 100
	enable_auto_scaling = false 
    availability_zones  = ["1", "2", "3"]
    node_count          = 1
    min_count           = null
    max_count           = null
    max_pods            = 110
    node_labels         = {}
    taints              = []
  }
}


```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azure"></a> [azure](#requirement\_azure) | >= 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 1.22.11 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |


## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resource/resource_group) | resource |
| [azurerm_kubernetes_cluster.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vnet) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_additional_node_pool"></a> [create\_additional\_node\_pool](create\_additional\_node\_pool) | (Optional) Use for condition if we want to create additional_node_pool | `bool` | n/a | yes |
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | (Optional) List of additional node pools to the cluster | <pre>map(object({<br>    vm_size             = string<br>    os_disk_size_gb     = number<br>    enable_auto_scaling = bool<br>    availability_zones  = list(string)<br>    node_count          = number<br>    min_count           = number<br>    max_count           = number<br>    max_pods            = number<br>    node_labels         = map(string)<br>    taints              = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_auto_scaling_default_node"></a> [auto\_scaling\_default\_node](#input\_auto\_scaling\_default\_node) | (Optional) Kubernetes Auto Scaler must be enabled for this main pool | `bool` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created. | `list(string)` | `[]` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). | `string` | `"10.0.0.10"` | no |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | (Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). | `string` | `"1.23.5"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_max_pods"></a> [max\_pods](#input\_max\_pods) | (Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. | `number` | `110` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | (Optional) The initial number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100 and between min\_count and max\_count. | `string` | n/a | yes |
| <a name="input_node_max_count"></a> [node\_max\_count](#input\_node\_max\_count) | (Required) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100. | `number` | n/a | yes |
| <a name="input_node_min_count"></a> [node\_min\_count](#input\_node\_min\_count) | (Required) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100. | `number` | n/a | yes |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | (Required) It defines the networking solution used to handle network communication between containers running within a Kubernetes cluster. |`string` | n/a | yes |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | (Optional) The CIDR to use for pod IP addresses. Changing this forces a new resource to be created. | `string` | `"10.244.0.0/16"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Base name used by resources (cluster name, main service and others). | `string` | n/a | yes |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | (Required) Network subnet name. | `string` | n/a | yes |
| <a name="input_network_vnet"></a> [network\_vnet](#input\_network\_vnet) | (Required) Virtual network name. | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | (Optional) The Network Range used by the Kubernetes service.Changing this forces a new resource to be created. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | (Optional) Defines the SLA plan for the availability of system. Valid options are Free or Paid, paid option enables the Uptime SLA feature (see https://docs.microsoft.com/en-us/azure/aks/uptime-sla for more info) | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | (Required) The size of the Virtual Machine, such as Standard\_DS2\_v2. | `string` | `"Standard_DS2_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name to be used in the context of kubectl |
| <a name="output_kube_config_file"></a> [kube\_config\_file](#output\_kube\_config\_file) | Kubeconfig file |
<!-- END_TF_DOCS -->

## Authors

Module managed by [TO THE NEW Pvt. Ltd.](https://github.com/tothenew)

## License

Apache 2 Licensed. See [LICENSE](https://github.com/tothenew/terraform-azure-aks/blob/main/LICENSE) for full details.