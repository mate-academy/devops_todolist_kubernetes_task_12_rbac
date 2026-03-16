# Validation Instructions

## Prerequisites
- Docker daemon is running
- `kind` and `kubectl` are installed

## 1. Create kind cluster from config
```bash
kind create cluster --name todoapp-rbac --config cluster.yml
kubectl cluster-info --context kind-todoapp-rbac
```

## 2. Deploy infrastructure
```bash
bash bootstrap.sh
```

## 3. Validate RBAC resources
```bash
kubectl -n todoapp get serviceaccount secrets-reader
kubectl -n todoapp get role secrets-reader -o yaml
kubectl -n todoapp get rolebinding secrets-reader -o yaml
```

## 4. Validate Deployment uses ServiceAccount
```bash
kubectl -n todoapp get deployment todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```
Expected output:
```text
secrets-reader
```

## 5. List secrets from the Deployment pod with curl
```bash
POD=$(kubectl -n todoapp get pods -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
kubectl -n todoapp exec "$POD" -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -sS --cacert "$CACERT" \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
'
```
Expected result: JSON output that includes a list of `todoapp` namespace secrets.

## 6. Cleanup
```bash
kind delete cluster --name todoapp-rbac
```
