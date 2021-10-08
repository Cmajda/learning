terraform {
  required_version = ">= 0.14"
  backend "azurerm" {
    subscription_id      = "7c0b0559-b933-4d68-9d8c-bf39d8711da0"
    tenant_id            = "67b7de17-01a8-410a-a645-3eacd61c1111"
    resource_group_name  = "rg-ne-shareddata"
    storage_account_name = "sanetfstate"
    container_name       = "con-ne-helocicd"
    key                  = "terraform.tfstate"
  }
}

terraform {
  required_providers {
    azurerm = {
      version = "~> 2.57.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
}

provider "helm" {
  alias = "provider_helm_aks"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
    password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  alias = "provider_ku_aks"

  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
  password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)

}
