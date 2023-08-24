module "aks_main" {

  source                  = "git::https://https://github.com/tothenew/terraform-azure-aks.git?ref=aks-v1"
  resource_group          = "RG_for_AKS"
  location                = "eastus2"
  vm_size                 = "Standard_DS2_v2"
  virtual_network_address = "10.0.0.0/8"
  subnet_address          = "10.0.1.0/16"

  create_additional_node_pool = true

  # if create_additional_node_pool = true then Add node pool configurations

  additional_node_pools = {

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
