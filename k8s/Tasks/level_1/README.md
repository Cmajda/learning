<!-- TOC -->
- [1. Úkol](#1-úkol)
    - [1.1. Principy definice a správa zdrojů](#11-principy-definice-a-správa-zdrojů)
    - [1.2. Typy zdrojů](#12-typy-zdrojů)
<!-- /TOC -->

# 1. Úkol  
Seznámit se se základními principy definice a správy zdrojů v Kubernetes:

## 1.1. Principy definice a správa zdrojů
- veškeré definice jsou deklarativní - určujeme desired state a cluster pomocí svých controllerů zajistí, že tento požadovaný stav bude nejen naplněn, ale též udržován vždy v souladu s definicí a také měněn v souladu se změnami definice
- každá definice zdroje obsahuje
    - GVK, neboli group, version, kind
    - metadata
    - vlastní definici - spec / data / cokoliv jiného
    - zpětnou vazbu - status
- kube api server
- controller, control loop, CRD, operator
## 1.2. Typy zdrojů
- namespace
- pod ([doc](https://kubernetes.io/docs/concepts/workloads/pods/))
- deployment ([doc](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/))
- configMap ([doc](https://kubernetes.io/docs/concepts/configuration/configmap/))
- secret
- service ([doc](https://kubernetes.io/docs/concepts/services-networking/service/))

