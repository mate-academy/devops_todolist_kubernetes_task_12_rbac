# Instructions

## Deploy

```bash
bash bootstrap.sh
```

## Validate

### 1. ServiceAccount создан

```bash
kubectl get serviceaccount -n todoapp
```

Expected: `todoapp-sa` в списке

### 2. Role и RoleBinding созданы

```bash
  kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
```

### 3. Deployment использует ServiceAccount

```bash
kubectl get pod -n todoapp -o jsonpath='{.items[0].spec.serviceAccountName}'
```

Expected: `todoapp-sa`

### 4. Curl запрос для листинга секретов

```bash
kubectl exec -it -n todoapp deploy/todoapp -- \
  curl -s \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```

Expected: JSON ответ со списком секретов namespace `todoapp`