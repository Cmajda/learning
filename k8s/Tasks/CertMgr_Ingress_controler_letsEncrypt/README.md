# Prepare Branch
```
git checkout -q -b Task/CertMgr-Ingres-LetsEncrypt --no-track master
```
# Task

Tento LAB je zaměřen na různá nastavení `Ingress` z pohledu TLS certifikátů.  
Nasadit aplikaci "hello-kubernetes" která standartně komunikuje jen HTTP (80), vystavit šifrovaně HTTPS(443) pod doménovým jménem hello-selfsigned.<DOMAIN> s maximálním využitím připravených komponent.  
článek [zde](https://kube-labs.notion.site/kube-labs/Copy-of-AKS-DNS-CertManager-Ingress-Controller-LetsEncrypt-e1903e963f264b6baa0893107816a6ce)

# Technoligie

Použijeme tyto technologie:

- `Terraform`
- `AKS` - prostředí
- `NGINX` - ingress controller
- `CertManager` - správce certifikátů
- `Let's Encrypt` - vydavatel certifikátů

Pro usnadnění práce použijeme tyto doplňkové technologie:

- `Azure DNS` - správa DNS záznamů
- `External DNS` - automatický provisioning DNS záznamů
- `Hello-kubernetes` - testovací aplikace
# Prerekvizity
## Proměnné
```
# Subscription ID (az group list -o table)
export SUB_ID=<SUB_ID> 

# Resource group name pro AKS a DNS zonu (az group list -o table)
export AKS_RG=<AKS_RG>

# Resource group s AKS VM (az group list -o table)
export AKS_RG_VM=<AKS_RG_VM>

# Jmeno AKS clusteru (az aks list -o table)
export AKS_NAME=<AKS_NAME>

# Jmeno DNS zony (az network dns zone list -o table)
export AKS_DNS=<AKS_DNS>

# Email pro Let's encrypt
export LE_EMAIL=<LE_EMAIL>

# Nový Kubeconfig (KUBE_CONFIG_PATH=/home/<user>/.kube/config_hello-kubernetes)
export KUBE_CONFIG_PATH=<KUBECONFIG_PATH>

# NameSpace pro aplikaci (lze změnit v akscontent.tf)
export HELLO_KUBERNETES=hello-kubernetes
```

## Azure

- Aks
- Azure DNS zóna

Infrastrukture je vytvořena pomocí Terraform skripty jsou v adresáři [Terraform](/infra)

## Kubeconfig
>:bulb: **pokud se merguje kubeconfig je nutné v terraform uptavit [`providers.tf`](/infra/providers.tf) index clusteru `azurerm_kubernetes_cluster.aks.kube_config.`0`.host`**
```
# nastevaní aktuální subscription
az account set --subscription $SUB_ID


# Uložení Clusteru do nového Kubeconfig 
az aks get-credentials --resource-group $AKS_RG --name $AKS_NAME -f $KUBE_CONFIG_PATH

# Nastavení contextu
kubectl config use-context $AKS_NAME --namespace=$HELLO_KUBERNETES
```
# Nasazení aplikace Hello-Kubernetes
```
git clone https://github.com/paulbouwer/hello-kubernetes.git
 
# Install nebo upgrade & pripadne vytvoreni namespace / ReleaseName & HelmChart & Namespace \
helm upgrade --install --create-namespace $HELLO_KUBERNETES hello-kubernetes/deploy/helm/hello-kubernetes/ -n $HELLO_KUBERNETES
  ```


# AAD pod Identity 
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
helm repo update

## Deployment Helm chartu
helm upgrade --install --create-namespace aad-pod-identity aad-pod-identity/aad-pod-identity -n aad-pod-identity --set mic.replicas=1