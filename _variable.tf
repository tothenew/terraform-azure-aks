variable "resource_group" {
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
  default     = "Central India"
}

variable "prefix" {
  description = "(Required) Base name used by resources (cluster name, main service and others)."
  type        = string
  default     = "SpecialChem_DevK8s"
}

variable "k8s_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  type        = string
  default     = "1.28.5"
}

variable "vnet_subnet_id" {
  type = string
}

variable "vnet_address_space" {
  type = string
}

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "service_cidr" {
  type = string
}

variable "support_plan" {
  type        = string
  default     = "KubernetesOfficial"
  description = "The support plan which should be used for this Kubernetes Cluster. Possible values are `KubernetesOfficial` and `AKSLongTermSupport`."
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = null
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off."
}

variable "azure_policy_enabled" {
  type        = bool
  default     = false
  description = "Enable Azure Policy Addon."
}
variable "dns_prefix" {
  type    = string
  default = "specialDevk8s"
}
variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "tags" {
  description = "Azure resource tags"
  default     = {}
}

variable "name_prefix" {
  description = "Used in tags cluster and nodes"
  type        = string
  default     = "AKS"
}

variable "default_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    "CreatedBy" : "TTN"
  }
}

variable "common_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    Project    = "SpecialChem"
    Managed-By = "TTN"
  }
}

variable "additional_node_pools" {
  description = "(Optional) List of additional node pools to the cluster"
  type = map(object({
    vm_size             = string
    os_disk_size_gb     = number
    enable_auto_scaling = bool
    availability_zones  = list(string)
    node_count          = number
    min_count           = number
    max_count           = number
    max_pods            = number
    node_labels         = map(string)
    taints              = list(string)
  }))
  default = {
    "qa" = {
      vm_size             = "Standard_DS2_v2"
      os_disk_size_gb     = 52
      enable_auto_scaling = true
      availability_zones  = []
      node_count          = 1
      min_count           = 1
      max_count           = 10
      max_pods            = 110
      node_labels         = {}
      taints              = []
    }
  }
}

variable "create_additional_node_pool" {
  type    = bool
  default = false
}

variable "oms_log_analytics_workspace_id" {
  type    = string
  default = ""
}

variable "load_balancer_profile_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable a load_balancer_profile block. This can only be used when load_balancer_sku is set to `standard`."
  nullable    = false
}

variable "load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "(Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created."

  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Possible values are `basic` and `standard`"
  }
}

variable "load_balancer_profile_idle_timeout_in_minutes" {
  type        = number
  default     = 30
  description = "(Optional) Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between `4` and `120` inclusive."
}

variable "load_balancer_profile_managed_outbound_ip_count" {
  type        = number
  default     = null
  description = "(Optional) Count of desired managed outbound IPs for the cluster load balancer. Must be between `1` and `100` inclusive"
}

variable "load_balancer_profile_outbound_ip_prefix_ids" {
  type        = set(string)
  default     = null
  description = "(Optional) The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer."
}

variable "load_balancer_profile_outbound_ip_address_ids" {
  type        = set(string)
  default     = null
  description = "(Optional) The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer."
}

variable "load_balancer_profile_managed_outbound_ipv6_count" {
  type        = number
  default     = null
  description = "(Optional) The desired number of IPv6 outbound IPs created and managed by Azure for the cluster load balancer. Must be in the range of `1` to `100` (inclusive). The default value is `0` for single-stack and `1` for dual-stack. Note: managed_outbound_ipv6_count requires dual-stack networking. To enable dual-stack networking the Preview Feature Microsoft.ContainerService/AKS-EnableDualStack needs to be enabled and the Resource Provider re-registered, see the documentation for more information. https://learn.microsoft.com/en-us/azure/aks/configure-kubenet-dual-stack?tabs=azure-cli%2Ckubectl#register-the-aks-enabledualstack-preview-feature"
}

variable "load_balancer_profile_outbound_ports_allocated" {
  type        = number
  default     = 0
  description = "(Optional) Number of desired SNAT port for each VM in the clusters load balancer. Must be between `0` and `64000` inclusive. Defaults to `0`"
}
variable "outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`."
  type        = string
  default     = "loadBalancer"
}

variable "aks_pod_cidr" {
  description = "CIDR used by pods when network plugin is set to `kubenet`."
  type        = string
  default     = "10.41.22.0/22"
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                   = optional(string, "default")
    node_count             = optional(number, 1)
    vm_size                = optional(string, "Standard_D2_v3")
    os_type                = optional(string, "Linux")
    workload_runtime       = optional(string, null)
    zones                  = optional(list(number), [1, 2])
    enable_auto_scaling    = optional(bool, false)
    min_count              = optional(number, 1)
    max_count              = optional(number, 10)
    type                   = optional(string, "VirtualMachineScaleSets")
    node_labels            = optional(map(any), null)
    orchestrator_version   = optional(string, null)
    priority               = optional(string, null)
    enable_host_encryption = optional(bool, null)
    eviction_policy        = optional(string, null)
    max_pods               = optional(number, 30)
    os_disk_type           = optional(string, "Managed")
    os_disk_size_gb        = optional(number, 128)
    enable_node_public_ip  = optional(bool, false)
    scale_down_mode        = optional(string, "Delete")
  })
  default = {}
}

variable "auto_scaler_profile" {
  description = "Configuration of `auto_scaler_profile` block object"
  type = object({
    balance_similar_node_groups      = optional(bool, false)
    expander                         = optional(string, "random")
    max_graceful_termination_sec     = optional(number, 600)
    max_node_provisioning_time       = optional(string, "15m")
    max_unready_nodes                = optional(number, 3)
    max_unready_percentage           = optional(number, 45)
    new_pod_scale_up_delay           = optional(string, "10s")
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string, "10s")
    scale_down_delay_after_failure   = optional(string, "3m")
    scan_interval                    = optional(string, "10s")
    scale_down_unneeded              = optional(string, "10m")
    scale_down_unready               = optional(string, "20m")
    scale_down_utilization_threshold = optional(number, 0.5)
    empty_bulk_delete_max            = optional(number, 10)
    skip_nodes_with_local_storage    = optional(bool, true)
    skip_nodes_with_system_pods      = optional(bool, true)
  })
  default = null
}

variable "key_vault_secrets_provider" {
  description = "Enable AKS built-in Key Vault secrets provider. If enabled, an identity is created by the AKS itself and exported from this module."
  type = object({
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string, "")
  })
  default = null
}

variable "private_cluster_enabled" {
  description = "Configure AKS as a Private Cluster."
  type        = bool
  default     = true
}

variable "private_dns_zone_type" {
  type        = string
  default     = "System"
  description = <<EOD
- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private_dns_zone_id> variable
If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"
and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone
- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group
- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.
EOD
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is custom"
}

variable "node_resource_group" {
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
  type        = string
  default     = null
}

variable "oidc_issuer_enabled" {
  description = "Whether to enable OpenID Connect issuer or not."
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "Whether HTTP Application Routing is enabled."
  type        = bool
  default     = false
}

variable "aks_http_proxy_settings" {
  description = "AKS HTTP proxy settings. URLs must be in format `http(s)://fqdn:port/`. When setting the `no_proxy_url_list` parameter, the AKS Private Endpoint domain name and the AKS VNet CIDR must be added to the URLs list."
  type = object({
    http_proxy_url    = optional(string)
    https_proxy_url   = optional(string)
    no_proxy_url_list = optional(list(string), [])
    trusted_ca        = optional(string)
  })
  default = null
}

variable "local_account_disabled" {
  type        = bool
  default     = null
  description = "(Optional) - If `true` local accounts will be disabled. Defaults to `false`."
}

variable "node_os_channel_upgrade" {
  type        = string
  default     = null
  description = " (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`."
}

variable "open_service_mesh_enabled" {
  type        = bool
  default     = null
  description = "Is Open Service Mesh enabled?"
}