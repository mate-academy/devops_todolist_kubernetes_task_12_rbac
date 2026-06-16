# Validation Instructions — Task 12 (RBAC)

These steps validate that a dedicated `ServiceAccount` (`secrets-reader`) is
allowed to **list Secrets** in the `todoapp` namespace, that the application
`Deployment` runs under that ServiceAccount, and that a `curl` from inside the
pod against the Kubernetes API succeeds.

## What was added

- **`security/rbac.yml`** — a `ServiceAccount`, a `Role` (allows `get`/`list`
  on `secrets`), and a `RoleBinding` that binds the Role to the ServiceAccount,
  all in the `todoapp` namespace.
- **`.infrastructure/app/deployment.yml`** — already sets
  `serviceAccountName: secrets-reader` so the app pods use this account.
- **`bootstrap.sh`** — applies `security/rbac.yml` before the Deployment.

## Prerequisites

- `docker` running
- `kind`
- `kubectl`

## Steps

### 1. Create the cluster

```bash
kind create cluster --config cluster.yml --name todoapp
```

### 2. Deploy the app (includes RBAC)

```bash
./bootstrap.sh
```

`bootstrap.sh` applies `security/rbac.yml` before `deployment.yml`, so the
`secrets-reader` ServiceAccount exists before the Deployment that references
it. Wait for the pods to become ready:

```bash
kubectl rollout status deploy/todoapp -n todoapp
```

> If you deployed before adding RBAC, just apply the manifest on its own:
> `kubectl apply -f security/rbac.yml`

### 3. Verify the RBAC objects exist

```bash
kubectl get serviceaccount,role,rolebinding -n todoapp
```

Expected: a `serviceaccount/secrets-reader`, a `role.rbac.authorization.k8s.io/secrets-reader`,
and a `rolebinding.rbac.authorization.k8s.io/secrets-reader`.

Inspect the Role rules and the binding:

```bash
kubectl describe role secrets-reader -n todoapp
kubectl describe rolebinding secrets-reader -n todoapp
```

### 4. Confirm the Deployment uses the ServiceAccount

```bash
kubectl get deploy todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

Expected output: `secrets-reader`

### 5. List secrets with `curl` from inside the pod (screenshot this)

```bash
POD=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n todoapp "$POD" -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $TOKEN" \
    https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
```

Expected: HTTP 200 with a JSON `SecretList` object that includes `app-secret`.
Because the bound Role grants `list` on `secrets`, the request is authorized.

> **If `curl` is not present in the pod image** (`ikulyk404/todoapp:4.0.1`),
> use one of these fallbacks:
>
> - Prove the permission directly (no pod needed):
>   ```bash
>   kubectl auth can-i list secrets -n todoapp \
>     --as=system:serviceaccount:todoapp:secrets-reader
>   ```
>   Expected: `yes`
>
> - Or run the curl from a throwaway pod bound to the ServiceAccount:
>   ```bash
>   kubectl run rbac-check -n todoapp --rm -i --restart=Never \
>     --image=curlimages/curl:latest \
>     --overrides='{"spec":{"serviceAccountName":"secrets-reader"}}' -- \
>     sh -c 'curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
>       -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
>       https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
>   ```

### 6. Negative control (optional, proves the Role is what grants access)

The cluster `default` ServiceAccount has no such permission, so the same
request returns `403 Forbidden`:

```bash
kubectl auth can-i list secrets -n todoapp \
  --as=system:serviceaccount:todoapp:default
```

Expected: `no`

## Cleanup

```bash
kind delete cluster --name todoapp
```
