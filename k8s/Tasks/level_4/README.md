# 1. Úkol  
Vyzkoušejte a napište všechny způsoby (včetně konkrétní podoby příkazu), které vás napadnou, jak:
- spustit nginx
- naškálovat na 3 repliky
- zobrazit všechny pody tohoto deploymentu včetně IP adresy a nodu
- totéž, ale tentokrát jméno podu a image
- switch na novější verzi
- nastavit ENV proměnnou NGINX_INSTANCE=nginx1
- vytvořit secret "nginx", data:
- username: nginx
- password: heslo
- vypsat hodnotu z pole "password" z tohoto secretu v plain textu
- zpřístupnit data z tohoto secretu do nginx kontejnerů
- restartovat nginx (a zde se i zamyslete nad výhodami a navýhodami jednotlivých postupů)
- Dále si vyzkoušejte mazání zdrojů za různých okolností - opět všechny varianty, které vás napadnou
- vytvořte deployment a service pro nginx a libovolnou configMap
- zobrazte jedním příkazem všechny tyto zdroje
- a smažte
vyzkoušejte si na deploymentu nginx:
- mazání deploymentu kaskádově a bez kaskády - co všechno se smaže a co zůstane
- mazání s finalizerem

# 2. Postup

## 2.1. spustit nginx
pomocí příkazu  
```
kubectl run nginx --image=nginx
```
a nebo  
```
kubectl run nginx --image=nginx --port=80 --labels="app=level_4"
```

pomocí yaml  
`kubectl apply -f ./yamlfile.yaml`
```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: level_4
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
```
## 2.2. Naškálovat na 3 repliky /vytvorit deployment?
```
apiVersion: app/v1
kind: Deployment
metadata: 
  name: nginx-deployment
  spec:
    replicas: 3
    selector:
      matchlabels:
      app: level_4
    template:
      metadata:
        lables:
        app: level_4
      spec:
        containers:
        - name: nginx
          image: nginx
```
kubectl get pods --selector=app=level_4 -o wide
kubectl get pods --selector="app=level_4" -o=name
kubectl get pods --selector="app=level_4" -o=name |  sed "s/^.\{4\}//"
kubectl get pods --selector="app=level_4" --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
