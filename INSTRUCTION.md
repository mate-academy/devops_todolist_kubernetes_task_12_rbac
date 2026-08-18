# Kubernetes RBAC Validation Instructions

## 1. Create the kind cluster
```bash
kind create cluster --config cluster.yml
```

Verify that the node is running:
```bash
kubectl get nodes
```

## 2. Create the todoapp namespace
```bash
kubectl apply -f .infrastructure/namespace.yml
```

## 3. Apply the RBAC configuration
```bash
kubectl apply -f .infrastructure/security/rbac.yml
```

Verify the created resources:
```bash
kubectl get serviceaccount -n todoapp
kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
```

## 4. Deploy the application
```bash
kubectl apply -f .infrastructure/app/deployment.yml
```

Check the Pods:
```bash
kubectl get pods -n todoapp
```

Verify that the Deployment Pods use the `secrets-reader` ServiceAccount:
```bash
kubectl get pod -n todoapp -o jsonpath="{.items[0].spec.serviceAccountName}"
```

## 5. List Secrets from the Deployment Pod

Get the name of a running Deployment Pod:
```bash
kubectl get pods -n todoapp
```

Open a shell inside the Pod:
```bash
kubectl exec -it <pod-name> -n todoapp -- sh
```

Read the ServiceAccount token:
```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
```

Use the token to query the Kubernetes API:
```bash
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```
