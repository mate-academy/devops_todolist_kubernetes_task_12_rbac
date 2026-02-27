# Validation Instructions

## 1. Prerequisites

- Docker is running
- `kind` is installed
- `kubectl` is installed

## 2. Create cluster from `cluster.yml`

```bash
kind create cluster --name todo-rbac --config cluster.yml
```

If cluster creation fails with `port is already allocated` (for example `0.0.0.0:80`), stop or delete the conflicting cluster/container and run the command again.

## 3. Deploy manifests

```bash
bash bootstrap.sh
```

## 4. Validate RBAC objects

```bash
kubectl -n todoapp get sa secrets-reader
kubectl -n todoapp get role secrets-reader-role -o yaml
kubectl -n todoapp get rolebinding secrets-reader-binding -o yaml
```

Expected:
- `ServiceAccount` exists: `secrets-reader`
- `Role` contains `resources: ["secrets"]` and `verbs: ["list"]`
- `RoleBinding` binds `secrets-reader-role` to `ServiceAccount/secrets-reader`

## 5. Validate Deployment uses ServiceAccount

```bash
kubectl -n todoapp get deployment todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

Expected output:

```text
secrets-reader
```

## 6. Run curl from Deployment pod to list secrets

```bash
POD=$(kubectl -n todoapp get pod -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
kubectl -n todoapp exec "$POD" -- sh -c 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt; NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace); curl -sS --cacert "$CACERT" -H "Authorization: Bearer $TOKEN" "https://kubernetes.default.svc/api/v1/namespaces/$NS/secrets"'
```

Expected output contains:

```text
"kind": "SecretList"
```

## 7. Screenshot for PR

- Save screenshot of terminal output from step 6 and attach it to PR.
- Example artifact generated in this repository: `artifacts/curl-secrets-output.png`
