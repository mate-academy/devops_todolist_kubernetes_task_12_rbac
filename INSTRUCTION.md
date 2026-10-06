# Task 12: RBAC (list Secrets)

## Prerequisites

- Docker, [kind](https://kind.sigs.k8s.io/), `kubectl`

## Deploy

```bash
kind delete cluster --name kind 2>/dev/null || true
chmod +x bootstrap.sh
./bootstrap.sh
```

RBAC manifest: **`.infrastructure/security/rbac.yml`** (ServiceAccount, Role, RoleBinding in namespace `todoapp`).

## Validate RBAC objects

```bash
kubectl get serviceaccount secrets-reader -n todoapp
kubectl get role secrets-reader-role -n todoapp
kubectl get rolebinding secrets-reader-role-binding -n todoapp
kubectl describe role secrets-reader-role -n todoapp
```

Role must allow **`list`** on **`secrets`** in the core API group.

## Validate Deployment uses the ServiceAccount

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

Expected: `secrets-reader`

```bash
POD=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
kubectl get pod "$POD" -n todoapp -o jsonpath='{.spec.serviceAccountName}{"\n"}'
```

## List Secrets from inside the Deployment pod (curl)

The pod uses the mounted service account token to call the Kubernetes API.

```bash
POD=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n todoapp "$POD" -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
  curl -sS -k \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://kubernetes.default.svc/api/v1/namespaces/${NS}/secrets"
'
```

You should get JSON with `"kind": "SecretList"` and items such as `app-secret` (metadata names; values are not included in a list response).

If `curl` is missing in the image, run the same request from a debug pod with the same ServiceAccount:

```bash
kubectl run -n todoapp curl-rbac --rm -it --restart=Never \
  --image=curlimages/curl:8.5.0 \
  --overrides='{"spec":{"serviceAccountName":"secrets-reader"}}' -- \
  sh -c 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace); curl -sS -k -H "Authorization: Bearer ${TOKEN}" "https://kubernetes.default.svc/api/v1/namespaces/${NS}/secrets"'
```

## PR screenshot

Attach a screenshot of the **curl output** (SecretList JSON) to the pull request, as required by the task README.

## Negative check (optional)

A pod without this Role should get **403 Forbidden** when listing secrets with its default token.

## Clean up

```bash
kind delete cluster --name kind
```
