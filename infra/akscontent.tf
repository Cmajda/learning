# Helms
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

# Namespaces
resource "kubernetes_namespace" "example" {
  provider = kubernetes.provider_ku_aks
  depends_on = [
    helm_release.certmanager
  ]
  metadata {
    name = "hello-ci-cd"
  }
}

resource "kubernetes_namespace" "hello-kubernetes" {
  provider = kubernetes.provider_ku_aks
  depends_on = [
    helm_release.certmanager
  ]
  metadata {
    name = "hello-kubernetes"
  }
}

resource "kubernetes_namespace" "Mongodb" {
  provider = kubernetes.provider_ku_aks
  depends_on = [
    helm_release.certmanager
  ]
  metadata {
    annotations = {}
    labels      = {}
    name        = "mongo-db-test"
  }
}
