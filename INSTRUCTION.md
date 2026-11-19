# Validate RBAC

## 1. Create the cluster and deploy
```bash
kind delete cluster   # only if a cluster "kind" already exists
chmod +x bootstrap.sh
./bootstrap.sh
```
`bootstrap.sh` creates the kind cluster from `cluster.yml` and applies all manifests,
including `.infrastructure/security/rbac.yml`.

## 2. Check RBAC resources
```bash
kubectl get serviceaccount,role,rolebinding -n todoapp
```
You should see `secrets-reader` ServiceAccount, Role and RoleBinding.

```bash
kubectl auth can-i list secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-reader
```
Expected output: `yes`.

## 3. Check that the Deployment uses the ServiceAccount
```bash
kubectl rollout status deployment/todoapp -n todoapp --timeout=600s
kubectl get pods -n todoapp -o jsonpath="{.items[*].spec.serviceAccountName}"
```
Expected output: `secrets-reader`.

## 4. List secrets from the Deployment pod with curl
```bash
kubectl exec -n todoapp deploy/todoapp -- sh -c 'SA=/var/run/secrets/kubernetes.io/serviceaccount; curl -s --cacert $SA/ca.crt -H "Authorization: Bearer $(cat $SA/token)" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
```
Expected output: JSON `SecretList` that contains the `app-secret` item.
The same check runs automatically at the end of `bootstrap.sh`.
A screenshot of this output is attached to the PR.
