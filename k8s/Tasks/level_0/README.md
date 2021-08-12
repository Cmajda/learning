<!-- TOC -->
- [1. Úkol](#1-úkol)
    - [1.1. Kód](#11-kód)
- [2. Výstup](#2-výstup)
    - [2.1. Cluster list](#21-cluster-list)
        - [2.1.1. `k3d cluster list`](#211-k3d-cluster-list)
    - [2.2. Cluster list](#22-cluster-list)
        - [2.2.1. `kubectl get node`](#221-kubectl-get-node)
        - [2.2.2. `kubectl get node  -o wide`](#222-kubectl-get-node---o-wide)
        - [2.2.3. `kubectl get node/k3d-k3s-default-server-0  -o wide`](#223-kubectl-get-nodek3d-k3s-default-server-0---o-wide)
<!-- /TOC -->

# 1. Úkol  
Úkolem pro tento level je připravit si lokální Kubernetes cluster (k3d). Bude se jednat o dvounodový cluster - 1x control plane node (server) + 1x worker node (agent).
## 1.1. Kód
```
k3d cluster create --agents 1 --servers 1
```
# 2. Výstup
## 2.1. Cluster list
### 2.1.1. `k3d cluster list`
```
NAME          SERVERS   AGENTS   LOADBALANCER
k3s-default   1/1       1/1      true
```
## 2.2. Cluster list
### 2.2.1. `kubectl get node`
```
NAME                       STATUS   ROLES                  AGE    VERSION
k3d-k3s-default-server-0   Ready    control-plane,master   114m   v1.21.2+k3s1
k3d-k3s-default-agent-0    Ready    <none>                 114m   v1.21.2+k3s1
```

### 2.2.2. `kubectl get node  -o wide`
```
NAME                       STATUS   ROLES                  AGE    VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION                      CONTAINER-RUNTIME
k3d-k3s-default-server-0   Ready    control-plane,master   138m   v1.21.2+k3s1   172.23.0.2    <none>        Unknown    5.10.16.3-microsoft-standard-WSL2   containerd://1.4.4-k3s2
k3d-k3s-default-agent-0    Ready    <none>                 138m   v1.21.2+k3s1   172.23.0.3    <none>        Unknown    5.10.16.3-microsoft-standard-WSL2   containerd://1.4.4-k3s2
```

### 2.2.3. `kubectl get node/k3d-k3s-default-server-0  -o wide`
```
NAME                       STATUS   ROLES                  AGE    VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION                      CONTAINER-RUNTIME
k3d-k3s-default-server-0   Ready    control-plane,master   142m   v1.21.2+k3s1   172.23.0.2    <none>        Unknown    5.10.16.3-microsoft-standard-WSL2   containerd://1.4.4-k3s2
```