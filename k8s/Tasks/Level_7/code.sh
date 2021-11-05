#!/usr/bin/env bash

#https://sapphire-spice-b41.notion.site/LAB-RBAC-Simple-949b109d0b284b9489f0e0e71c171128
printf "\033c"
#set variables
shopt -s expand_aliases # aby fungovaly aliasy v skriptu
WORKINGDIR=~/.kube/Kcfg
export DEFKUBECONFIG=~/.kube/config
export AKSKUBECONFIG="${WORKINGDIR}/Kcfg"

KUBECONFIG=$DEFKUBECONFIG
echo -e "*** Kontrola Variables ***\nWORKINGDIR = ${WORKINGDIR}\nKUBECONFIG = ${KUBECONFIG}\nDEFKUBECONFIG = ${DEFKUBECONFIG}\nAKSKUBECONFIG = ${AKSKUBECONFIG}"
read -p "Press enter to continue"

echo -e "*** Create Working Dir ***\n${WORKINGDIR}"
mkdir $WORKINGDIR -p
cd $WORKINGDIR
pwd
ls -la

echo -e "*** Create aliases ***\n"
alias kc="kubectl --kubeconfig ${KUBECONFIG}"
alias kxa="kubectl --kubeconfig ${AKSKUBECONFIG} --context alice"
alias kxb="kubectl --kubeconfig ${AKSKUBECONFIG} --context bob"
alias kxmon="kubectl --kubeconfig ${AKSKUBECONFIG} --context monitor"
alias kxaud="kubectl --kubeconfig ${AKSKUBECONFIG} --context audit"
alias kxadm="kubectl --kubeconfig ${AKSKUBECONFIG} --context admin"

echo -e "*** Create namespace: \"alice\",\"bob\",\"developers\"***"
kubectl create ns alice
kubectl create ns bob
kubectl create ns developers
read -p "Press enter to continue"

echo -e "*** Kontrola namespaces: ***\n"
kubectl get namespaces alice bob developers
read -p "Press enter to continue"

echo -e "*** Vytvoření uživatelů přes certifikát:\"alice\",\"bob\"***"

echo -e "- *** Vytvoření privátních klíčů pro uživatele:\"alice\",\"bob\"***"
openssl req -new -newkey rsa:1024 -keyout alice.pem -nodes -out - -subj "/CN=alice/O=developers" 2>/dev/null | base64 -w0 > alice.csr
openssl req -new -newkey rsa:1024 -keyout bob.pem   -nodes -out - -subj "/CN=bob/O=developers"   2>/dev/null | base64 -w0 > bob.csr
read -p "Press enter to continue"

echo -e "- *** Vytvoření žádosti o certifikát pro uživatele:\"alice\",\"bob\",\"developers\"***"
cat <<EOF | kubectl create -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: alice
spec:
  request: $(cat alice.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

cat <<EOF | kubectl create -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: bob
spec:
  request: $(cat bob.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
read -p "Press enter to continue"

echo -e "- *** Kontrola žádosti:***\n"
kubectl get csr
read -p "Press enter to continue"

echo -e "- *** Schválení žádosti:***\n"

kubectl certificate approve alice
kubectl certificate approve bob
read -p "Press enter to continue"

echo -e "- *** stažení certifikátů:***\n"
kubectl get csr alice -o jsonpath='{.status.certificate}' | base64 -d > alice.crt
kubectl get csr bob   -o jsonpath='{.status.certificate}' | base64 -d > bob.crt
read -p "Press enter to continue"
ls -la

KUBECONFIG=$AKSKUBECONFIG # nastavení var KUBECONFIG aby používal nastavení z configu ~/.kube/Kcfg/Kcfg
kubectl config set-cluster alice --server $(kc config view --minify | yq e '.clusters[0].cluster.server' - )
kubectl config set-cluster bob --server $(kc config view --minify | yq e '.clusters[0].cluster.server' - )

kubectl config set-cluster alice --embed-certs --certificate-authority <(kc config view --minify --raw | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d)
kubectl config set-cluster bob --embed-certs --certificate-authority <(kc config view --minify --raw | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d)
read -p "Press enter to continue"

echo -e "*** Nastavení ověřování uživatele v ./kcfg pomocí certifikátu ***\n"
kubectl config set-credentials alice --embed-certs --client-key alice.pem --client-certificate alice.crt
kubectl config set-credentials bob --embed-certs --client-key bob.pem --client-certificate bob.crt
read -p "Press enter to continue"

echo -e "*** Nastavení kontextu ./kcfg ***\n"
kubectl config set-context alice --cluster alice --user alice --namespace=alice
kubectl config set-context bob --cluster bob --user bob --namespace=bob
read -p "Press enter to continue"

kubectl config view | grep "user: "
#k config view --kubeconfig ~/.kube/Kcfg/Kcfg | grep "user: "

echo -e "*** Nastavení deafult config ./kube./config ***\n"
KUBECONFIG=$DEFKUBECONFIG # zpet výchozí config
echo -e $KUBECONFIG
read -p "Press enter to continue"

echo -e "*** vytvoření rolebinding > uživatel adminem pro svůj namespace  ***\n"
kubectl create rolebinding alice-admin -n alice --clusterrole=admin --user=alice
kubectl create rolebinding bob-admin   -n bob   --clusterrole=admin --user=bob
kubectl get rolebindings -n alice
kubectl get rolebindings -n bob
read -p "Press enter to continue"

echo -e "*** Nastavení R/W skupine developers na namespace developers  ***\n"
kubectl create rolebinding developers-edit -n developers --clusterrole=edit --group=developers
kubectl get rolebindings -n developers
read -p "Press enter to continue"

echo -e "*** Alice Nastavení R/O na namesapce bob a obráceně ***\n"
kubectl create rolebinding alice-view -n bob   --clusterrole=view --user=alice
kubectl create rolebinding bob-view   -n alice --clusterrole=view --user=bob
kubectl get rolebindings -n alice
kubectl get rolebindings -n bob
kubectl get rolebindings -A -o json | jq '.items[]| select (((.metadata.namespace=="alice") or (.metadata.namespace == "bob")) and (.roleRef.name=="view")).metadata.name'
read -p "Press enter to continue"

echo -e "*** Vytvoření custom cluster role ***\n"
kubectl create clusterrole configmap-edit --resource=configMap --verb=create,delete,deletecollection,patch,update
kubectl get clusterroles.rbac.authorization.k8s.io -o json | jq '.items[].metadata|select ( .name == "configmap-edit").name'
#kubectl get --raw /api/v1 | jq '.resources[] | select ( .name == "configmaps" ).verbs'
read -p "Press enter to continue"

# rolebinding s názvem "alice-edit-cm" v namespace "bob" práva "RW" na resource "mapconfig" přiřazená uživateli "alice" 

echo -e "*** Přiřazení role configmap-edit uživatelům ***\n"
kubectl create rolebinding alice-edit-cm -n bob   --clusterrole=configmap-edit --user=alice
kubectl create rolebinding bob-edit-cm   -n alice --clusterrole=configmap-edit --user=bob
kubectl get rolebindings -n alice
kubectl get rolebindings -n bob
read -p "Press enter to continue"

echo -e "*** serviceAccount \"monitor\" v namespace \"default\" má R/O práva v namespace \"bob\", \"alice\", \"developers\""

#kubectl create rolebinding sa-monitor-view -n default -clusterrole=view --user=monitor  první pokus :-(

kubectl create sa sa-monitor -n default
kubectl create rolebinding sa-monitor -n alice      --clusterrole=view --serviceaccount=default:sa-monitor
kubectl create rolebinding sa-monitor -n bob        --clusterrole=view --serviceaccount=default:sa-monitor
kubectl create rolebinding sa-monitor -n developers --clusterrole=view --serviceaccount=default:sa-monitor
kubectl get rolebindings -n alice
kubectl get rolebindings -n alice
kubectl get rolebindings -n developers
read -p "Press enter to continue"

echo -e "serviceAccount \"sa-audit\" v namespace \"default\" má R/O práva na vše v clusteru"
kubectl create sa sa-audit -n default

kubectl create clusterrolebinding sa-audit --clusterrole=view --serviceaccount=default:sa-audit
kubectl get clusterrolebindings sa-audit
read -p "Press enter to continue"
KUBECONFIG=$AKSKUBECONFIG
echo $KUBECONFIG
read -p "Press enter to continue"

echo -e "Konfigurace kubectl kontexty "\sa-monitor\", "\sa-audit\""
kubectl config set-cluster sa-monitor --server $(kc config view --minify | yq e '.clusters[0].cluster.server' - )
kubectl config set-cluster sa-audit   --server $(kc config view --minify | yq e '.clusters[0].cluster.server' - )

kubectl config set-cluster sa-monitor --embed-certs --certificate-authority <(kc config view --minify --raw | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d)
kubectl config set-cluster sa-audit   --embed-certs --certificate-authority <(kc config view --minify --raw | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d)
read -p "Press enter to continue"
 
echo -e "Nastavení credentials "\sa-monitor\", "\sa-audit\""
kubectl config set-credentials sa-monitor --token $(kubectl get secrets $(kubectl get serviceaccounts sa-monitor -o json | jq -r '.secrets[].name') --template={{.data.token}} | base64 -d)
kubectl config set-credentials sa-audit   --token $(kubectl get secrets $(kubectl get serviceaccounts sa-audit -o json | jq -r '.secrets[].name') --template={{.data.token}} | base64 -d)

