
data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "rg_ne_shareddata" {
  name = "rg-ne-shareddata"

}
resource "azurerm_resource_group" "rg_ne_aks" {
  name     = "rg-ne-${lower(var.projectname)}-aks"
  location = var.location
}

resource "azurerm_resource_group" "rg_ne_network" {
  name     = "rg-ne-${lower(var.projectname)}-network"
  location = var.location
  tags     = merge(azurerm_resource_group.rg_ne_aks.tags, { description = "Resource Group for networking" })
}

# NETWORKING

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ne-${lower(var.projectname)}"
  location            = azurerm_resource_group.rg_ne_network.location
  resource_group_name = azurerm_resource_group.rg_ne_network.name
  tags                = merge(azurerm_resource_group.rg_ne_aks.tags, { description = "NSG" })
}

/* resource "azurerm_network_ddos_protection_plan" "ddos_plan" {
  name                = "ddo-ne-${lower(var.projectname)}"
  location            = azurerm_resource_group.rg_ne_network.location
  resource_group_name = azurerm_resource_group.rg_ne_network.name
} */

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ne-${lower(var.projectname)}"
  location            = azurerm_resource_group.rg_ne_network.location
  resource_group_name = azurerm_resource_group.rg_ne_network.name
  address_space       = ["10.192.0.0/16"] #10.0.0.0/16
  tags                = merge(azurerm_resource_group.rg_ne_aks.tags, { description = "Vnet for project hello CI/CD" })

  /*   ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos_plan.id
    enable = false
  } */
}

resource "azurerm_subnet" "subnet_aks" {
  name                 = "sub-ne-${lower(var.projectname)}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  address_prefixes     = ["10.192.11.160/27"] #10.0.0.0/16
}

resource "azurerm_public_ip" "aks_ingress_ip" {
  name                = "${azurerm_kubernetes_cluster.aks.name}-ingress-pip"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  domain_name_label   = "${azurerm_kubernetes_cluster.aks.name}-ingress-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(azurerm_resource_group.rg_ne_aks.tags, { description = "Ingress ip for aks" })


}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet_aks.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = azurerm_resource_group.rg_ne_aks.name
  location            = var.location
  name                = "${var.projectname}-aks-uami"
  tags                = merge(azurerm_resource_group.rg_ne_aks.tags, { description = "Use manage Identity of AKS aks-ne-${lower(var.projectname)}" })
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-ne-${lower(var.projectname)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ne_aks.name
  dns_prefix          = "${var.projectname}-aks"
  node_resource_group = "${var.projectname}-aks"
  sku_tier            = "Free"
  tags                = merge(azurerm_resource_group.rg_ne_aks.tags, { description = "AKS for Application ${var.aks_application_list}" })

  default_node_pool {
    name               = "default"
    node_count         = "1"
    availability_zones = ["1"]
    vm_size            = "Standard_E2S_v3"
    vnet_subnet_id     = azurerm_subnet.subnet_aks.id
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
  }

  role_based_access_control {
    enabled = true
  }

}

resource "azurerm_container_registry" "acr" {
  name                = "acrne${lower(var.projectname)}"
  resource_group_name = data.azurerm_resource_group.rg_ne_shareddata.name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = merge(local.default_tags, { description = "container registry form images and helm" })
}


resource "helm_release" "ingress-nginx" {
  provider = helm.provider_helm_aks
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.34.0"
  namespace  = "ingress-nginx"

  wait              = true
  wait_for_jobs     = true
  create_namespace  = true
  dependency_update = true


  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.aks_ingress_ip.ip_address
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.config.server-tokens"
    value = "false"
    type  = "string"
  }
}

resource "helm_release" "certmanager" {
  provider = helm.provider_helm_aks
  depends_on = [
    helm_release.ingress-nginx
  ]

  name       = "certmanager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.5.4"
  namespace  = "cert-manager"

  wait             = true
  wait_for_jobs    = true
  create_namespace = true


  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_namespace" "example" {
  provider = kubernetes.provider_ku_aks
  depends_on = [
    helm_release.certmanager
  ]
  metadata {
    name = "hello-ci-cd"
  }
}
