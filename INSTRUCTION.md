# Instructions: validating the RBAC changes

This change adds a `ServiceAccount`, a `Role` and a `RoleBinding` (`.infrastructure/security/rbac.yml`) and makes the `todoapp` Deployment use that ServiceAccount, so a pod can list Secrets in its own namespace through the Kubernetes API.

## What was changed

- `.infrastructure/security/rbac.yml` (new), in the `todoapp` namespace:
  - `ServiceAccount` `secrets-reader`
  - `Role` `secrets-reader` – allows `list` on `secrets`
  - `RoleBinding` `list-secrets` – binds the Role to the ServiceAccount
- `.infrastructure/app/deployment.yml` – added `serviceAccountName: secrets-reader`.
- `bootstrap.sh` – applies `rbac.yml` right after the `todoapp` namespace is created.
- `.infrastructure/app/pv.yml` – removed `namespace` (PersistentVolume is cluster-scoped).

## Prerequisites

`docker`, `kind`, `kubectl`.

## Steps

1. Create the cluster:

   ```bash
   kind create cluster --config cluster.yml
   ```

2. Deploy everything:

   ```bash
   bash bootstrap.sh
   ```

3. Check that the RBAC objects exist:

   ```bash
   kubectl get serviceaccount,role,rolebinding -n todoapp
   ```

   Expected: `secrets-reader` (ServiceAccount and Role) and `list-secrets` (RoleBinding).

4. Wait until the pod is ready and confirm it uses the new ServiceAccount:

   ```bash
   kubectl rollout status deployment/todoapp -n todoapp
   kubectl get pods -n todoapp -o jsonpath='{.items[*].spec.serviceAccountName}'
   ```

   Expected output: `secrets-reader`.

5. Check permissions with `kubectl auth can-i`:

   ```bash
   kubectl auth can-i list secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-reader   # yes
   kubectl auth can-i delete secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-reader # no
   ```

6. List secrets with `curl` from inside the Deployment pod:

   ```bash
   POD=$(kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

   kubectl exec -n todoapp "$POD" -- sh -c '
     TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
     CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
     curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
       https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
   '
   ```

   Expected: a `SecretList` JSON that includes the `app-secret` secret (HTTP 200).
   If the image has no `curl`, use `kubectl debug` with a curl image, or `wget`/`python` inside the pod with the same URL and headers.

7. Negative check – the account must not have other permissions (for example, listing pods):

   ```bash
   kubectl exec -n todoapp "$POD" -- sh -c '
     TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
     curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
       -H "Authorization: Bearer $TOKEN" \
       https://kubernetes.default.svc/api/v1/namespaces/todoapp/pods
   '
   ```

   Expected: a `Status` JSON with `"code": 403` (`Forbidden`).

## Cleanup

```bash
kind delete cluster
```
