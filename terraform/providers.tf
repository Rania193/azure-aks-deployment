terraform {
required_version = ">= 1.6.0"
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = ">= 3.99.0"
}
kubernetes = {
source = "hashicorp/kubernetes"
version = ">= 2.27.0"
}
helm = {
source = "hashicorp/helm"
version = ">= 2.13.0"
}
}
}


provider "azurerm" {
features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
}
}


# These two are configured from AKS kube_config once cluster is created
provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "aks-microservices"
}


provider "helm" {
    kubernetes = {
        config_path    = "~/.kube/config"
        config_context = "aks-microservices"
    }
}