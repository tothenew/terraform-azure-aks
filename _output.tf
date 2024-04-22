output "kube_config_file" {
  description = "Kubeconfig file"
  value       = local_file.kubeconfig.filename
  # sensitive = true
}

output "cluster_name" {
  description = "Cluster name to be used in the context of kubectl"
  value       = azurerm_kubernetes_cluster.aks_cluster.name
}

output "cluster_id" {
  description = "Describe the Cluster ID"
  value = azurerm_kubernetes_cluster.aks_cluster.id 
}

