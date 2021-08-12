#!/bin/sh
ROOT_FOLDER="`dirname \"$0\"`"
kubectl apply -f ./$ROOT_FOLDER/dashboard-adminuser.yaml
kubectl apply -f ./$ROOT_FOLDER/cluster-role-binding.yaml
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-k8swebgui -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"