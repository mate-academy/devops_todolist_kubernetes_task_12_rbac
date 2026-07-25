# Validation Instructions

This document explains how to spin up the cluster, deploy the app, and verify
that the `secrets-reader` ServiceAccount can list Secrets in the `todoapp`
namespace via the Kubernetes API, from inside the running pod.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

## 1. Create the kind cluster

```bash
kind create cluster --name todoapp --config cluster.yml
kubectl cluster-info --context kind-todoapp
```

## 2. Deploy MySQL

```bash
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl -n mysql rollout status statefulset/mysql
```

## 3. Deploy the RBAC resources (ServiceAccount, Role, RoleBinding)

```bash
kubectl apply -f .infrastructure/security/rbac.yml
```

Verify the objects were created:

```bash
kubectl -n todoapp get serviceaccount secrets-reader
kubectl -n todoapp get role secrets-reader-role
kubectl -n todoapp get rolebinding secrets-reader-binding
```

> Note: the `ns.yml` in `.infrastructure/app/` must be applied before this
> step, since the ServiceAccount/Role/RoleBinding live in the `todoapp`
> namespace. Apply it first if you haven't yet:
> `kubectl apply -f .infrastructure/app/ns.yml`

## 4. Deploy the todoapp

```bash
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/ingress/ingress.yml

kubectl -n todoapp rollout status deployment/todoapp
```

Confirm the pod is actually using the `secrets-reader` ServiceAccount:

```bash
kubectl -n todoapp get pods -l app=todoapp \
  -o jsonpath='{.items[0].spec.serviceAccountName}'
# expected output: secrets-reader
```

## 5. List Secrets from inside the pod (proves the RBAC works)

Exec into the running todoapp pod:

```bash
POD=$(kubectl -n todoapp get pods -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
kubectl -n todoapp exec -it "$POD" -- sh
```

Inside the pod, use the ServiceAccount token that Kubernetes automatically
mounts at `/var/run/secrets/kubernetes.io/serviceaccount/` to call the API
server and list Secrets in the `todoapp` namespace:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

curl -s \
  --cacert "$CACERT" \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```

A successful call returns a JSON `SecretList` (HTTP 200) containing the
`app-secret` object — this confirms the `Role`/`RoleBinding` correctly grants
the `secrets-reader` ServiceAccount permission to `list` Secrets in the
`todoapp` namespace. Take a screenshot of this output for the PR.

To sanity-check that RBAC is actually being enforced (not just "any
authenticated user can do this"), you can optionally repeat the same curl
command against a namespace the Role does *not* grant access to (e.g.
`mysql`) and confirm it returns `403 Forbidden`:

```bash
curl -s \
  --cacert "$CACERT" \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/mysql/secrets
```

## 6. Clean up

```bash
kind delete cluster --name todoapp
```

## Summary of what's being validated

| Requirement | How it's validated |
|---|---|
| `ServiceAccount` defined | `kubectl -n todoapp get serviceaccount secrets-reader` |
| `Role` defined, allows `list` on `secrets` | `kubectl -n todoapp get role secrets-reader-role -o yaml` |
| `RoleBinding` defined, binds Role to ServiceAccount | `kubectl -n todoapp get rolebinding secrets-reader-binding -o yaml` |
| Deployment uses the ServiceAccount | `spec.template.spec.serviceAccountName: secrets-reader` in `.infrastructure/app/deployment.yml`, confirmed live via `jsonpath` query above |
| ServiceAccount can list Secrets | `curl` from inside the pod against the Kubernetes API returns the Secret list (HTTP 200) |