provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-test-demo"
  location = "Central India"
}

module "log_analytics" {
  source = "git::https://github.com/tothenew/terraform-azure-loganalytics.git"
  workspace_name          = "devspecialtest-log"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  diagnostic_setting_name = "devspeciattest-log-diagnostic-setting"

  diagnostic_setting_enabled_metrics = {
    "AllMetrics" = {
      enabled           = true
      retention_days    = 30
      retention_enabled = true
    }
  }
  common_tags = {
    "createdBy" : "terraform"
  }
}

data "azurerm_subscription" "subscription" {}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  name                       = "devspeciattest-activity-logs"
  target_resource_id         = data.azurerm_subscription.subscription.id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Security"
  }
}

module "vnet" {
  source              = "git::https://github.com/tothenew/terraform-azure-vnet.git"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = "10.41.0.0/20"

  virtual_network_peering = false

  subnets = {
    "subnet1" = {
      address_prefixes           = ["10.41.1.0/24"]
      associate_with_route_table = false 
      is_natgateway              = false
      is_nsg                     = true
      service_delegation         = false
    }
  }
}
module "aks_main" {

  source                      = "../.."
  resource_group              = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  vnet_subnet_id              = module.vnet.subnet_ids["subnet1"] 
  service_cidr                = "10.41.16.0/22"

  oms_log_analytics_workspace_id = module.log_analytics.workspace_id


  create_additional_node_pool = true
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
