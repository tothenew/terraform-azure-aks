locals {
  default_agent_profile = {
    name                   = var.default_node_pool.name
    node_count             = var.default_node_pool.node_count
    vm_size                = var.default_node_pool.vm_size
    os_type                = var.default_node_pool.os_type
    workload_runtime       = var.default_node_pool.workload_runtime
    zones                  = var.default_node_pool.zones
    enable_auto_scaling    = var.default_node_pool.enable_auto_scaling
    min_count              = var.default_node_pool.min_count
    max_count              = var.default_node_pool.max_count
    type                   = var.default_node_pool.type
    node_labels            = var.default_node_pool.node_labels
    orchestrator_version   = var.default_node_pool.orchestrator_version
    priority               = var.default_node_pool.priority
    enable_host_encryption = var.default_node_pool.enable_host_encryption
    eviction_policy        = var.default_node_pool.eviction_policy
    vnet_subnet_id         = var.vnet_subnet_id
    max_pods               = var.default_node_pool.max_pods
    os_disk_type           = var.default_node_pool.os_disk_type
    os_disk_size_gb        = var.default_node_pool.os_disk_size_gb
    enable_node_public_ip  = var.default_node_pool.enable_node_public_ip
    scale_down_mode        = var.default_node_pool.scale_down_mode
  }

  default_node_pool = merge(local.default_agent_profile, var.default_node_pool)
}
