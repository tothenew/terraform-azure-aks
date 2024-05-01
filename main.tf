resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                             = var.prefix
  resource_group_name              = var.resource_group
  location                         = var.location
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.k8s_version
  sku_tier                         = var.sku_tier
  support_plan                     = var.support_plan
  local_account_disabled           = var.local_account_disabled
  node_os_channel_upgrade          = var.node_os_channel_upgrade
  open_service_mesh_enabled        = var.open_service_mesh_enabled
  automatic_channel_upgrade        = var.automatic_channel_upgrade
  azure_policy_enabled             = var.azure_policy_enabled
  private_cluster_enabled          = var.private_cluster_enabled
  private_dns_zone_id              = var.private_cluster_enabled ? local.private_dns_zone : null
  node_resource_group              = var.node_resource_group
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  default_node_pool {
    name                = local.default_node_pool.name
    vm_size             = local.default_node_pool.vm_size
    zones               = local.default_node_pool.zones
    enable_auto_scaling = local.default_node_pool.enable_auto_scaling
    node_count          = local.default_node_pool.enable_auto_scaling ? null : local.default_node_pool.node_count
    min_count           = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.min_count : null
    max_count           = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.max_count : null
    max_pods            = local.default_node_pool.max_pods
    os_disk_type        = local.default_node_pool.os_disk_type
    os_disk_size_gb     = local.default_node_pool.os_disk_size_gb
    type                = local.default_node_pool.type
    vnet_subnet_id      = local.default_node_pool.vnet_subnet_id
    node_labels         = local.default_node_pool.node_labels
    scale_down_mode     = local.default_node_pool.scale_down_mode

    tags = merge(var.default_tags, var.common_tags, tomap({
      "Name" : "${var.name_prefix}",
      "Environment" : "Dev"
    }))
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = try(auto_scaler_profile.value.balance_similar_node_groups, null)
      expander                         = try(auto_scaler_profile.value.expander, null)
      max_graceful_termination_sec     = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time       = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes                = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage           = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay           = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add       = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete    = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure   = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scan_interval                    = try(auto_scaler_profile.value.scan_interval, null)
      scale_down_unneeded              = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready               = try(auto_scaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold = try(auto_scaler_profile.value.scale_down_utilization_threshold, null)
      empty_bulk_delete_max            = try(auto_scaler_profile.value.empty_bulk_delete_max, null)
      skip_nodes_with_local_storage    = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods      = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }
  identity {
    type = "SystemAssigned"
  }

  # oms_agent {
  #   log_analytics_workspace_id = var.oms_log_analytics_workspace_id != "" ? var.oms_log_analytics_workspace_id : data.azurerm_log_analytics_workspace.example.workspace_id 
  # }

  dynamic "oms_agent" {
    for_each = var.oms_log_analytics_workspace_id != "" ? [1] : []
    content {
      log_analytics_workspace_id = var.oms_log_analytics_workspace_id
    }
  }

  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_plugin == "azure" ? "azure" : null
    network_mode      = var.network_plugin == "azure" ? "transparent" : null
    dns_service_ip    = cidrhost(var.service_cidr, 10)
    service_cidr      = var.service_cidr
    load_balancer_sku = var.load_balancer_sku
    outbound_type     = var.outbound_type
    pod_cidr          = var.network_plugin == "kubenet" ? var.aks_pod_cidr : null
    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile_enabled && var.load_balancer_sku == "standard" ? [
        "load_balancer_profile"
      ] : []

      content {
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated
      }
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider[*]
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.aks_http_proxy_settings != null ? ["enabled"] : []
    content {
      http_proxy  = var.aks_http_proxy_settings.http_proxy_url
      https_proxy = var.aks_http_proxy_settings.https_proxy_url
      no_proxy    = distinct(flatten(concat(local.default_no_proxy_url_list, var.aks_http_proxy_settings.no_proxy_url_list)))
      trusted_ca  = var.aks_http_proxy_settings.trusted_ca
    }
  }

  tags = merge(var.default_tags, var.common_tags, tomap({
    "Name" : "${var.name_prefix}",
    "Environment" : "Dev"
  }))
}


##################################################################################################
#### Kubernetes Config File ####
##################################################################################################

resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}

##################################################################################################
####  Azure Kubernetes Cluster Additional Node_Pool ####
##################################################################################################

resource "azurerm_kubernetes_cluster_node_pool" "aks" {

  for_each = var.create_additional_node_pool ? var.additional_node_pools : {}

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id

  name                = substr(each.key, 0, 12)
  vm_size             = each.value.vm_size
  os_disk_size_gb     = each.value.os_disk_size_gb
  enable_auto_scaling = each.value.enable_auto_scaling
  node_count          = each.value.node_count
  min_count           = each.value.min_count
  max_count           = each.value.max_count
  max_pods            = each.value.max_pods
  node_labels         = each.value.node_labels
  node_taints         = each.value.taints
  vnet_subnet_id      = var.vnet_subnet_id

  tags = merge(var.default_tags, var.common_tags, {
    "Name" = "${var.name_prefix}-repo",
    "Environment" : "Dev"
  })
}
