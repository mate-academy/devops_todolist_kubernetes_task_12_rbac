# How to validate RBAC changes

## What was changed

- `.infrastructure/security/rbac.yml` contains:
  - `ServiceAccount` `secrets-reader`
  - `Role` `secrets-reader` that allows `get` and `list` on `secrets`
  - `RoleBinding` `secrets-reader` that binds the Role to the ServiceAccount
- `.infrastructure/app/deployment.yml` uses `serviceAccountName: secrets-reader`
- `bootstrap.sh` applies `rbac.yml` right after the `todoapp` namespace is created

## 1. Create the cluster

```bash
kind create cluster --config cluster.yml
```

## 2. Deploy all resources

```bash
bash bootstrap.sh
```

## 3. Wait until the application pods are ready

```bash
kubectl get pods -n todoapp
```

All `todoapp-*` pods should be `Running` with `1/1` ready.

## 4. Check permissions without entering a pod

```bash
kubectl auth can-i list secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-reader
```

Expected output: `yes`

## 5. List secrets from inside the pod

```bash
kubectl exec -it <todoapp-pod-name> -n todoapp -- sh
```

Inside the pod run:

```bash
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.