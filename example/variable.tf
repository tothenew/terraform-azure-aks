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