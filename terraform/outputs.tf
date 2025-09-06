output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server # reg endpoint
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "azure_client_id" {
  description = "The client id (application id) of the identity running Terraform"
  value       = module.github_oidc.azuread_application.client_id
  sensitive   = false
}

output "azure_tenant_id" {
  description = "The tenant id of the identity running Terraform"
  value       = data.azurerm_client_config.current.tenant_id
  sensitive   = false
}

output "azure_subscription_id" {
  description = "The subscription id being used"
  value       = data.azurerm_client_config.current.subscription_id
  sensitive   = false
}

output "github_oidc_app_object_id" {
  value = coalesce(module.github_oidc.azuread_application.object_id, module.github_oidc.azuread_application.id)
}
output "github_oidc_sp_object_id" {
  value = coalesce(module.github_oidc.service_principal.object_id, module.github_oidc.service_principal.id)
}