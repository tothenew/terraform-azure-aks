##################################################################################################
####  Azure Resource Group ####
##################################################################################################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

##################################################################################################
####  Azure Kubernetes Cluster ####
##################################################################################################

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.k8s_version
  sku_tier             = var.sku_tier

  default_node_pool {
    name                = "dev"
    vm_size             = var.vm_size
    enable_auto_scaling = var.auto_scaling_default_node
    node_count          = var.node_count
    min_count           = var.node_min_count
    max_count           = var.node_max_count
    max_pods            = var.max_pods
}

  identity {
    type = "SystemAssigned"
  }

  dynamic "network_profile" {
    for_each = var.network_plugin == "kubenet" ? [1] : []
    content {
      network_plugin = var.network_plugin
    }
  }

  dynamic "network_profile" {
    for_each = var.network_plugin == "azure" ? [1] : []
    content {
      network_plugin       = var.network_plugin
      network_plugin_mode  = "Overlay"
      dns_service_ip       = var.dns_service_ip
      pod_cidr             = var.pod_cidr
      service_cidr         = var.service_cidr
    }
  }
  
dynamic "ingress_application_gateway" {
    for_each = try(var.ingress_application_gateway.gateway_id, null) == null ? [] : [1]

    content {
      gateway_id                 = var.ingress_application_gateway.gateway_id
      subnet_cidr                = var.ingress_application_gateway.subnet_cidr
      subnet_id                  = var.ingress_application_gateway.subnet_id
    }
  }

   tags = var.tags
}


##################################################################################################
#### Kubernetes Config File ####
##################################################################################################

resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.cluster]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

##################################################################################################
####  Azure Kubernetes Cluster Additional Node_Pool ####
##################################################################################################

resource "azurerm_kubernetes_cluster_node_pool" "aks" {

  for_each = var.create_additional_node_pool ? var.additional_node_pools : {}

  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
 
  name                  = substr(each.key, 0, 12)
  vm_size               = each.value.vm_size
  os_disk_size_gb       = each.value.os_disk_size_gb
  enable_auto_scaling   = each.value.enable_auto_scaling
  node_count            = each.value.node_count
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  max_pods              = each.value.max_pods
  node_labels           = each.value.node_labels
  node_taints           = each.value.taints

   tags = merge(var.default_tags, var.common_tags , {
    "Name"        = "${var.name_prefix}-repo",
  })
}

##################################################################################################
####  Azure Virtual Network ####
##################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-k8s"
  address_space       = [var.virtual_network_address]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  count               = var.virtual_network_name == "" ? 1 : 0
   tags = merge(var.default_tags, var.common_tags , {
    "Name"        = "${var.name_prefix}-repo",
  })
}

##################################################################################################
####  Azure Subnet ####
##################################################################################################

resource "azurerm_subnet" "subnet" {
  count                = var.subnet_network_name == "" ? 1 : 0
  name                 = "subnet-k8s"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = var.virtual_network_name == "" ? azurerm_virtual_network.vnet[0].name : var.virtual_network_name
  address_prefixes     = var.virtual_network_name == "" ? ["10.240.0.0/16"] : [var.subnet_address]
}


