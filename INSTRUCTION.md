# Task 12: RBAC

## Requirements

- Docker Desktop
- kind
- kubectl
- Git Bash (or any bash shell)

## How to run

```bash
bash bootstrap.sh
```

The script creates the kind cluster from `cluster.yml` and applies the MySQL, app and RBAC manifests.

## What was added

- `security/rbac.yml` contains a ServiceAccount `secrets-reader`, a Role `secrets-reader-role` (verb `list` on `secrets`) and a RoleBinding `secrets-reader-binding` that binds the Role to the ServiceAccount, all in the namespace `todoapp`.
- The Deployment uses this ServiceAccount (`serviceAccountName: secrets-reader`).

## How to validate

1. Wait until the pods are Running (the app pods may restart once while MySQL starts):

```bash
kubectl get pods -A
```

2. List the secrets from the Deployment pod (replace the pod name):

```bash
MSYS_NO_PATHCONV=1 kubectl exec -n todoapp <todoapp-pod> -- sh -c 'curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
```

Expected result: JSON with `"kind": "SecretList"` and the secret `app-secret`. Without the Role and RoleBinding the API answers `forbidden`.

## Notes

- Secrets in this repository are demo values for a local cluster only.
