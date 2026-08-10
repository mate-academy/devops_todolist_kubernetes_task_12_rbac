# Task 12 (RBAC) — validation instructions

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- [kind](https://kind.sigs.k8s.io/) and `kubectl` in PATH
- Repository cloned locally

## 1. Create the kind cluster

From the repository root (the **`cluster.yml`** file is in the repo root):

```bash
kind create cluster --config cluster.yml
kubectl config use-context kind-kind
kubectl get nodes
```

Expect **5 nodes** (1 control-plane + 4 workers), as defined in `cluster.yml`.

## 2. Deploy infrastructure

`bootstrap.sh` applies resources in order: MySQL, namespace **`todoapp`**, RBAC (`.infrastructure/security/rbac.yml`), then the app manifests including Deployment.

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Or on Windows (PowerShell), apply the same files manually (**namespace `todoapp` before RBAC and Deployment**):

```powershell
kubectl apply -f .infrastructure/mysql/
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/security/rbac.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml
```

Wait for MySQL and the app:

```bash
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=300s
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
kubectl get pods -n todoapp
```

Pod should be **`1/1 Running`** and **`Ready`**.

## 3. Verify RBAC manifest

RBAC file: **`.infrastructure/security/rbac.yml`**

```bash
kubectl get serviceaccount pods-lister -n todoapp
kubectl get role pods-lister -n todoapp -o yaml
kubectl get rolebinding pods-lister-binding -n todoapp
```

Role rules must include **`secrets`** with verb **`list`** (and typically `get`).

Deployment must use the ServiceAccount:

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

Expected: `pods-lister`

## 4. List secrets from inside the Deployment pod (curl)

Replace pod name if needed:

```bash
POD=$(kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n todoapp "$POD" -- sh -c \
  'curl -sSk -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
```

**Success:** JSON with `"kind": "List"` and items including `app-secret`.  
**Failure (403):** Role does not allow `list` on `secrets`, or wrong ServiceAccount on the Deployment.

Take a **screenshot** of this output for the PR.

### Windows PowerShell (quoting)

PowerShell may break `sh -c` with `$(cat ...)`. Use two steps:

```powershell
$token = (kubectl exec -n todoapp deploy/todoapp -- cat /var/run/secrets/kubernetes.io/serviceaccount/token).Trim()
kubectl exec -n todoapp deploy/todoapp -- curl -sSk -H "Authorization: Bearer $token" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```

Expect `"kind": "SecretList"` and `app-secret` in the output.

## 5. Optional — app via NodePort

```bash
kubectl get svc -n todoapp
```

Use the NodePort mapped in `nodeport.yml` (if nodes expose it on kind).

## 6. Tear down

```bash
kind delete cluster --name kind
```
