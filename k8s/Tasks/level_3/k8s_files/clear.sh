#!/usr/bin/bash
ROOT_FOLDER="`dirname \"$0\"`"
NAMESPACE="nsp-httppublisher"
echo -e "Delete namespace $NAMESPACE"
kubectl delete namespace $NAMESPACE
kubectl config set-context --current --namespace default