- [1. Prepare Branch](#1-prepare-branch)
- [2. Task](#2-task)
- [3. Technoligie](#3-technoligie)
- [4. Prerekvizity](#4-prerekvizity)
	- [4.1. Proměnné](#41-proměnné)
	- [4.2. Azure](#42-azure)
	- [4.3. Kubeconfig](#43-kubeconfig)
- [5. Nasazení aplikace Hello-Kubernetes](#5-nasazení-aplikace-hello-kubernetes)
- [6. AAD pod Identity](#6-aad-pod-identity)
	- [6.1. Deployment Helm chartu](#61-deployment-helm-chartu)
	- [vytvoření potřebných rolí v Azure](#vytvoření-potřebných-rolí-v-azure)
	- [Založení AzureIdentity a AzureIdentityBinding](#založení-azureidentity-a-azureidentitybinding)
	- [External DNS](#external-dns)
- [Nastavení Helm repository na klientovi](#nastavení-helm-repository-na-klientovi)
- [Deployment Helm chartu](#deployment-helm-chartu)


# 1. Prepare Branch
```
git checkout -q -b Task/CertMgr-Ingres-LetsEncrypt --no-track master
```
# 2. Task

Tento LAB je zaměřen na různá nastavení `Ingress` z pohledu TLS certifikátů.  
Nasadit aplikaci "hello-kubernetes" která standartně komunikuje jen HTTP (80), vystavit šifrovaně HTTPS(443) pod doménovým jménem hello-selfsigned.<DOMAIN> s maximálním využitím připravených komponent.  
článek [zde](https://kube-labs.notion.site/kube-labs/Copy-of-AKS-DNS-CertManager-Ingress-Controller-LetsEncrypt-e1903e963f264b6baa0893107816a6ce)

# 3. Technoligie

Použijeme tyto technologie:

- `Terraform` - vztvo5en9 infrastrukurz
- `AKS` - prostředí
- `NGINX` - ingress controller
- `CertManager` - správce certifikátů
- `Let's Encrypt` - vydavatel certifikátů

Pro usnadnění práce použijeme tyto doplňkové technologie:
- `Azure DNS` - správa DNS záznamů
- `External DNS` - automatický provisioning DNS záznamů
- `Hello-kubernetes` - testovací aplikace


# 4. Prerekvizity
## 4.1. Proměnné
```
# Subscription ID (az account list -o table)
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

## 4.2. Azure

- Aks
- Azure DNS zóna

Infrastrukture je vytvořena pomocí Terraform skripty jsou v adresáři [Terraform](/infra)

## 4.3. Kubeconfig
>:bulb: **pokud se merguje kubeconfig je nutné v terraform uptavit [`providers.tf`](/infra/providers.tf) index clusteru `azurerm_kubernetes_cluster.aks.kube_config.`0`.host`**
```
# nastevaní aktuální subscription
az account set --subscription $SUB_ID


# Uložení Clusteru do nového Kubeconfig 
az aks get-credentials --resource-group $AKS_RG --name $AKS_NAME -f $KUBE_CONFIG_PATH

# Nastavení contextu
kubectl config use-context $AKS_NAME --namespace=$HELLO_KUBERNETES
```
# 5. Nasazení aplikace Hello-Kubernetes
```
git clone https://github.com/paulbouwer/hello-kubernetes.git
 
# Install nebo upgrade & pripadne vytvoreni namespace / ReleaseName & HelmChart & Namespace \
helm upgrade --install --create-namespace $HELLO_KUBERNETES hello-kubernetes/deploy/helm/hello-kubernetes/ -n $HELLO_KUBERNETES
  ```


# 6. AAD pod Identity 
```
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
helm repo update
```


>:warning: **aad-pod-identity-nmi - je v CrashLoopBackOff**

## 6.1. Deployment Helm chartu
```
helm upgrade --install --create-namespace aad-pod-identity aad-pod-identity/aad-pod-identity -n aad-pod-identity --set mic.replicas=1
```
>:warning: **Na WSL - vscode nefunguje používání proměnných u AZ commandů, musel jsem použít přímo string!!!**

## vytvoření potřebných rolí v Azure
 ```
export AKS_KUBELET_CLIENTID=$(az aks show -n "${AKS_NAME}" -g "${AKS_RG}" --query identityProfile.kubeletidentity.clientId -o tsv)
export AKS_DNS_ZONE_ID=$(az network dns zone show -n "${AKS_DNS}" -g "${AKS_RG_VM}" --query id -o tsv)
az role assignment create --assignee "${AKS_KUBELET_CLIENTID}" --role "DNS Zone Contributor" --scope "${AKS_DNS_ZONE_ID}"
az role assignment create --role "Reader" --assignee "${AKS_KUBELET_CLIENTID}" -g "${AKS_RG}"
az role assignment create --role "Reader" --assignee "${AKS_KUBELET_CLIENTID}" -g "${AKS_RG_VM}"
 ```
 ## Založení AzureIdentity a AzureIdentityBinding
 ```
 export AKS_KUBELET_RESOURCEID=$(az aks show -n "${AKS_NAME}" -g "${AKS_RG}" --query identityProfile.kubeletidentity.resourceId)
export AKS_KUBELET_CLIENTID=$(az aks show -n "${AKS_NAME}" -g "${AKS_RG}" --query identityProfile.kubeletidentity.clientId)

cat <<EOF | kubectl create -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: kubeletidentity
  namespace: aad-pod-identity
spec:
  type: 0
  resourceID: ${AKS_KUBELET_RESOURCEID}
  clientID: ${AKS_KUBELET_CLIENTID}
---
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: kubeletidentity-binding
  namespace: aad-pod-identity
spec:
  azureIdentity: kubeletidentity
  selector: kubeletidentity
EOF
 ```

 ## External DNS
 # Nastavení Helm repository na klientovi
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deployment Helm chartu
```
helm upgrade --install --create-namespace external-dns bitnami/external-dns -n external-dns --version 5.4.8 --set policy=sync --set provider=azure --set azure.tenantId=$(az account show --query tenantId -otsv) --set azure.subscriptionId=$(az account show --query id -otsv) --set azure.resourceGroup=${AKS_RG} --set azure.useManagedIdentityExtension=true --set podLabels.aadpodidbinding=kubeletidentity
```

check kubectl --namespace=external-dns get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns"