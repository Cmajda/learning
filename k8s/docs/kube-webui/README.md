# 1. install Web UI (Dashbord UI)
Deploying the Dashboard UI
The Dashboard UI is not deployed by default. To deploy it, run the following command:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

## 1.1. Accessing the Dashboard UI 
To protect your cluster data, Dashboard deploys with a minimal RBAC configuration by default. Currently, Dashboard only supports logging in with a Bearer Token. To create a token follow guide on creating a [sample user](../user/how-to-create-a-simple-user.md).

> ⚠️ **The sample user created in the tutorial will have administrative privileges and is for educational purposes only**
---
More info in documents page kubernetes [here](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)