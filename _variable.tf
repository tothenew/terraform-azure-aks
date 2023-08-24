variable "resource_group" {
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist."
  type        = string
  default     = "Resource_group"
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
  default     = "Central India"
}

variable "prefix" {
  description = "(Required) Base name used by resources (cluster name, main service and others)."
  type        = string
  default     = "new_kubernetes"
}

variable "k8s_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  type        = string
  default     = "1.26"
}

variable "vm_size" {
  description = "(Required) The size of the Virtual Machine, such as Standard_DS2_v2."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "auto_scaling_default_node" {
  description = "(Optional) Kubernetes Auto Scaler must be enabled for this main pool"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "(Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "node_count" {
  description = "(Optional) The initial number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100 and between min_count and max_count."
  type        = string
  default     = 1
}

variable "node_min_count" {
  description = "(Required) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "(Required) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 100."
  type        = number
  default     = 10
}

variable "max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent."
  type        = number
  default     = 50
}

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service.Changing this forces a new resource to be created."
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
  type        = string
  default     = "10.0.0.10"
}

variable "pod_cidr" {
  description = "(Optional) The CIDR to use for pod IP addresses."
  type        = string
  default     = "10.244.0.0/16"
}

variable "dns_prefix" {
  type    = string
  default = "k8stest"
}

variable "virtual_network_name" {
  description = "Virtual Network name"
  default     = "vnet-k8"
}

variable "subnet_network_name" {
  description = "Subnet netwotk name"
  default     = "subnet-k8s"
}

variable "virtual_network_address" {
  description = "Virtual network address"
  default     = "10.0.0.0/8"
}

variable "subnet_address" {
  description = "Subnet address"
  default     = "10.0.1.0/16"

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
  default     = "vnet"
}

variable "default_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    "Scope" : "VNET"
    "CreatedBy" : "Terraform"
  }
}

variable "common_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    Project    = "VNet"
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

variable "ingress_application_gateway" {
  description = "Specifies the Application Gateway Ingress Controller addon configuration."
  type = object({
    enabled      = bool
    gateway_id   = string
    gateway_name = string
    subnet_cidr  = string
    subnet_id    = string
  })
  default = {
    enabled      = false
    gateway_id   = null
    gateway_name = null
    subnet_cidr  = null
    subnet_id    = null
  }
}