resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}


resource "azurerm_container_registry" "acr" {
    name = var.acr_name
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Basic"
    admin_enabled = true
}


resource "azurerm_kubernetes_cluster" "aks" {
    name = var.aks_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix = "${var.prefix}-dns"


    default_node_pool {
        name = "system"
        node_count = var.node_count
        vm_size = var.node_vm_size
    }


    identity {
        type = "SystemAssigned"
    }


    kubernetes_version = var.kubernetes_version


    role_based_access_control_enabled = true
    local_account_disabled = false
}


# Allow AKS kubelet to pull from ACR
resource "azurerm_role_assignment" "acr_pull" {
    scope = azurerm_container_registry.acr.id
    role_definition_name = "AcrPull"
    principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}


# === Monitoring: kube-prometheus-stack via Helm ===
resource "kubernetes_namespace" "monitoring" {
    metadata { name = "monitoring" }
}

resource "helm_release" "kube_prom_stack" {
    name = "kube-prometheus-stack"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    namespace = kubernetes_namespace.monitoring.metadata[0].name

    values = [
        yamlencode({
            grafana = {
            service = { type = "ClusterIP" }
            resources = { requests = { cpu = "50m", memory = "128Mi" }, limits = { cpu = "200m", memory = "256Mi" } }
            }
            prometheus = {
                prometheusSpec = {
                resources = { requests = { cpu = "100m", memory = "256Mi" }, limits = { cpu = "300m", memory = "512Mi" } }
                }
            }
        })
    ]
}