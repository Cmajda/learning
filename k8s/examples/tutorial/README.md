
[bash auto-completion / alias](https://kubernetes.io/docs/tasks/tools/included)  
- `Alias kubectl`
```
echo 'alias ku=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl ku' >>~/.bashrc
```
- #### `k3d version`

```
3d version v4.4.8
k3s version v1.21.3-k3s1 (default)
```

- #### `ku version -o yaml`
```
clientVersion:
  buildDate: "2021-08-19T15:45:37Z"
  compiler: gc
  gitCommit: 632ed300f2c34f6d6d15ca4cef3d3c7073412212
  gitTreeState: clean
  gitVersion: v1.22.1
  goVersion: go1.16.7
  major: "1"
  minor: "22"
  platform: linux/amd64
serverVersion:
  buildDate: "2021-07-22T20:52:14Z"
  compiler: gc
  gitCommit: 1d1f220fbee9cdeb5416b76b707dde8c231121f2
  gitTreeState: clean
  gitVersion: v1.21.3+k3s1
  goVersion: go1.16.6
  major: "1"
  minor: "21"
  platform: linux/amd64
```
```
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')

echo Name of the Pod: $POD_NAME
```

![as](https://d33wubrfki0l68.cloudfront.net/7a13fe12acc9ea0728460c482c67e0eb31ff5303/2c8a7/docs/tutorials/kubernetes-basics/public/images/module_04_labels.svg)

```
kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}'
```