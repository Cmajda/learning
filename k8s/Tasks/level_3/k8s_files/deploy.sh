#!/usr/bin/bash
ROOT_FOLDER="`dirname \"$0\"`"
NAMESPACE="nsp-httppublisher"
echo -e "Creating deployment and services..."
kubectl apply -f ./$ROOT_FOLDER/httppublisher.yaml
kubectl config set-context --current --namespace $NAMESPACE 