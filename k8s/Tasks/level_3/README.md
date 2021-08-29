<!-- TOC -->
- [1. Úkol](#1-úkol)
- [2. Steps](#2-steps)
	- [2.1. Vytvoření Docker images](#21-vytvoření-docker-images)
		- [2.1.1. Server - `httppublisher`](#211-server---httppublisher)
		- [2.1.2. Client - `httpreader`](#212-client---httpreader)
	- [2.2. Push Docker images](#22-push-docker-images)
	- [2.3. K8S files](#23-k8s-files)
		- [2.3.1. Deployment](#231-deployment)
		- [2.3.2. Deploy na cluster](#232-deploy-na-cluster)
- [3. Výstup](#3-výstup)
	- [3.1. seznam requestu z `container` a jejich výsledek](#31-seznam-requestu-z-container-a-jejich-výsledek)
	- [3.2. seznam requestu z `localhost (bear metal)` a jejich výsledek](#32-seznam-requestu-z-localhost-bear-metal-a-jejich-výsledek)
	- [3.3. IP Adresy:](#33-ip-adresy)
		- [3.3.1. NODY](#331-nody)
		- [3.3.2. PODY](#332-pody)
		- [3.3.3. ENDPOINTY](#333-endpointy)
		- [3.3.4. SERVICES](#334-services)
	- [3.4. Rozsahy sítí (Cidr)](#34-rozsahy-sítí-cidr)
		- [3.4.1. Seznam cidr](#341-seznam-cidr)
- [4. HELP commands](#4-help-commands)
<!-- /TOC -->


# 1. Úkol  
- vytvořit kontejneru s programovou částí,který vypisuje jeden náhodný řádek ze souboru a tento řádek publikuje jako http response na http request.
- kontejner nahrát do container repository
- vytvořit servisu typu ClusterIP, která bude port na PODu referencovat `(selector)`
- pro kontejner vytvořit Deployment v k3d a nějakým způsobem se na port pro servisu připojit `(curl http://service-name:port)`
  - hinty: 
    - IP adresa podu by měla být v `kubectl get endpoints`
    - pokud se chcete připojit ze svého localhostu, je potřeba port forwardovat k vám `(kubectl port-forward)`
    - možnost je vytvořit si kontejner obsahující curl na tento kontejner se připojit `(kubectl exec ... a spustit curl ale pozor na adresu pro SVC)`
- pro ten samý kontejner vytvořte servisu typu NodePort
- test přístup ze svého localhostu
- zjistit rozsahy sítí pro:
  - PODY (pod CIDR)
  - NODY (node CIDR)
  - Služby (service CIDR)

# 2. Steps

## 2.1. Vytvoření Docker images
  
### 2.1.1. Server - `httppublisher`
- kompletní zdroje - [httppublisher](docker_files/httppublisher/)  

- [`httppublisher.sh`](docker_files/httppublisher/httppublisher.sh)

	```
	#!/bin/sh
	ROOT_FOLDER="`dirname \"$0\"`"
	r="`shuf -n 1 ./$ROOT_FOLDER/input_files/publish.txt`"
	while true
	do (
		r="`shuf -n 1 ./$ROOT_FOLDER/input_files/publish.txt`"
		echo -e 'HTTP/1.1 200 OK\r\n'
		echo -e "\r\n<H1>Learning k8s</H1>\r\n <H2>$r</H2>"
		) | timeout 1  nc -lp 8181
	done
	```
>:bulb: **nebo spustit: [`~$./build.sh`](docker_files/httppublisher/build.sh)**  

### 2.1.2. Client - `httpreader`
- kompletní zdroje - [httpreader](docker_files/httpreader/)  

- [`httpreader.sh`](docker_files/httpreader/httpreader.sh)  
	```
	#!/bin/sh
	while true
	do (
		curl -l http://localhost:8181
		curl -l http://svc-cl-httppublisher:8181
		)
	sleep 1
	done
	```
>:bulb: **nebo spustit: [`~$./build.sh`](docker_files/httpreader/build.sh)**  

## 2.2. Push Docker images
```
docker push cmajda/trask-k8s-httppublisher:1.0.3
```  
```
docker push cmajda/trask-k8s-httpreader:1.0.2
```

## 2.3. K8S files
- kompletní zdroje - [`K8s_files`](k8s_files/)

### 2.3.1. Deployment
- [`httppublisher.yaml`](k8s_files/namespace.yaml)  
  
	```
	#NAMESPACE
	apiVersion: v1
	kind: Namespace
	metadata:
	  name: nsp-httppublisher
	  labels:
	    app: httppublisher
	---
	#SVC CLUSTER_IP
	apiVersion: v1
	kind: Service
	metadata:
	  name: svc-cl-httppublisher
	  namespace: nsp-httppublisher
	spec:
	  selector:
	    app: httppublisher
	  ports:
	    - name: http
	      port: 8181
	      protocol: TCP
	      targetPort: 8181
	  type: ClusterIP
	---
	#DEPLOYMENT
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: dep-httppublisher
	  namespace: nsp-httppublisher
	spec:
	  selector:
	    matchLabels:
	      app: httppublisher
	  replicas: 1
	  template:
	    metadata:
	      namespace: nsp-httppublisher
	      labels:
	        app: httppublisher
	    spec:
	      containers:
	        - name: httppublisher
	          image: cmajda/trask-k8s-httppublisher:1.0.3
	          ports:
	            - containerPort: 8181
	              protocol: TCP
	          resources:
	            limits:
	              memory: "128Mi"
	              cpu: "250m"
	        - name: httpreader
	          image: cmajda/trask-k8s-httpreader:1.0.2
	          resources:
	            limits:
	              memory: "128Mi"
	              cpu: "250m"
	---
	#SVC NODEPORT
	apiVersion: v1
	kind: Service
	metadata:
	  name: svc-no-httppublisher
	  namespace: nsp-httppublisher
	  labels:
	    app: httppublisher
	spec:
	  selector:
	    app: httppublisher
	  type: NodePort
	  ports:
	    - targetPort: 8181
	      port: 8181
	      nodePort: 30081
	```
### 2.3.2. Deploy na cluster
	
```
kubectl apply -f ./httppublisher.yaml
```
```
kubectl config set-context --current --namespace nsp-httppublisher
```
>:bulb: **nebo spustit: [`~$./deploy.sh`](k8s_files/deploy.sh)**  


# 3. Výstup
## 3.1. seznam requestu z `container` a jejich výsledek
| Request                          | Result             | resource type                                        |
| -------------------------------- | ------------------ | ---------------------------------------------------- |
| http://localhost:8181            | ✔️                  | localhost container httppublisher                    |
| http://3d-default-agent-0:30081  | :heavy_check_mark: | node                                                 |
| http://172.18.0.2:30081          | ✔️                  | node                                                 |
| http://svc-cl-httppublisher:8181 | ✔️                  | EndPoint                                             |
| http://10.42.0.46:8181           | ✔️                  | EndPoint (svc-cl-httppublisher,svc-no-httppublisher) |
| http://10.43.184.32:8181         | ✔️                  | service / ClusterIP                                  |
| http://svc-no-httppublisher:8181 | ✔️                  | EndPoint                                             |
| http://10.43.208.64:8181         | ✔️                  | service / NodePort                                   |

## 3.2. seznam requestu z `localhost (bear metal)` a jejich výsledek
  

| Request                          | Result | Port forward | resource type                                        |
| -------------------------------- | ------ | ------------ | ---------------------------------------------------- |
| http://localhost:8181            | :x:    | :x:          | localhost container httppublisher                    |
| http://localhost:8181            | ✔️      | ✔️            | localhost container httppublisher                    |
| http://3d-default-agent-0:30081  | :x:    | :x:          | node                                                 |
| http://172.18.0.2:30081          | ✔️      | :x:          | node                                                 |
| http://svc-cl-httppublisher:8181 | :x:    | :x:          | EndPoint                                             |
| http://10.42.0.46:8181           | :x:    | :x:          | EndPoint (svc-cl-httppublisher,svc-no-httppublisher) |
| http://10.43.184.32:8181         | :x:    | :x:          | service / ClusterIP                                  |
| http://svc-no-httppublisher:8181 | :x:    | :x:          | EndPoint                                             |
| http://10.43.208.64:8181         | :x:    | :x:          | service / NodePort                                   |


## 3.3. IP Adresy:
### 3.3.1. NODY
`kubectl get nodes -o wide`  
```
NAME                   STATUS   ROLES                  AGE     VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION      CONTAINER-RUNTIME
k3d-default-server-0   Ready    control-plane,master   2d23h   v1.21.3+k3s1   172.18.0.2    <none>        Unknown    5.11.0-27-generic   containerd://1.4.8-k3s1
k3d-default-agent-0    Ready    <none>                 2d23h   v1.21.3+k3s1   172.18.0.3    <none>        Unknown    5.11.0-27-generic   containerd://1.4.8-k3s1
```
### 3.3.2. PODY
`kubectl get pods -o wide`  
```
NAME                                 READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
dep-httppublisher-6cf7df588f-2ltrm   2/2     Running   0          14h   10.42.1.61   k3d-default-agent-0    <none>           <none>
dep-httppublisher-6cf7df588f-4zk2q   2/2     Running   0          13h   10.42.0.46   k3d-default-server-0   <none>           <none>
```
### 3.3.3. ENDPOINTY
`kubectl get ep -o wide`  
```
NAME                   ENDPOINTS                         AGE
svc-cl-httppublisher   10.42.0.46:8181,10.42.1.61:8181   14h
svc-no-httppublisher   10.42.0.46:8181,10.42.1.61:8181   14h
```
### 3.3.4. SERVICES
`kubectl get services -o wide`  
```
NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE   SELECTOR
svc-cl-httppublisher   ClusterIP   10.43.184.32   <none>        8181/TCP         14h   app=httppublisher
svc-no-httppublisher   NodePort    10.43.208.64   <none>        8181:30081/TCP   14h   app=httppublisher
```

## 3.4. Rozsahy sítí (Cidr)
- Pokud pri vytváření clusteru nejsou definované rozsahy sítí , tak se (u K3d) použijí výchozí rozsahy. [Rancher - docs](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#networking)
- Výchozí hodnoty:  

| Resours      | Default      | Description                          |
| ------------ | ------------ | ------------------------------------ |
| cluster-cidr | 10.42.0.0/16 | Network CIDR to use for pod IPs      |
| service-cidr | 10.43.0.0/16 | Network CIDR to use for services IPs |

- vytvoření clusteru s nastavením rozsahu
	``` 
	k3d cluster create k3d-example-cidr \
	  --k3s-server-arg --cluster-cidr="10.118.0.0/17" \
	  --k3s-server-arg --service-cidr="10.118.128.0/17"
	```


### 3.4.1. Seznam cidr
- s nastavenýma rozsahama  
`kubectl cluster-info dump ayml | grep -i cidr`
	```
	"k3s.io/node-args": "[\"server\",\"--cluster-cidr\",\"10.118.0.0/17\",\"--service-cidr\",\"10.118.128.0/17\",\"--disable\",\"servicelb\",\"--disable\",\"traefik\",\"--tls-san\",\"0.0.0.0\"]",
	"podCIDR": "10.118.0.0/24"
	```
- bez nastavení (výchozí)
`kubectl cluster-info dump ayml | grep -i -m 1 cidr`  
	```
	"podCIDR": "10.42.0.0/24"
	```


# 4. HELP commands
- get CIDRs
```
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'  
kubectl get pods -o jsonpath='{.items[*].spec.podCIDR}'  
```
- Port-forward
```
kubectl port-forward deployments/httppublisher 8181:8181 -n default  
```

- Delete resources:
```
kubectl delete all -l app=dev na základe labelll  
kubectl delete all --all -n {namespace} na zaklade namespace  
kubectl delete namespace {namespace} nebo celý namespace  
```