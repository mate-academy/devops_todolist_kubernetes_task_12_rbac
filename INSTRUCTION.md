# Instruction

## Deploy

```bash
kind create cluster --config cluster.yml
bash bootstrap.sh
```

## Validate

### 1. Check ServiceAccount is created
```bash
kubectl get serviceaccount secrets-reader -n todoapp
```

### 2. Check Role is created
```bash
kubectl get role secrets-reader -n todoapp
```

### 3. Check RoleBinding is created
```bash
kubectl get rolebinding secrets-reader -n todoapp
```

### 4. Check Deployment uses the ServiceAccount
```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'
```
Expected: `secrets-reader`

### 5. List secrets from inside the pod
```bash
kubectl exec -it -n todoapp $(kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}') -- \
  curl -s -k \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```
Expected: JSON response with list of secrets in the `todoapp` namespace
