# RBAC Validation Instructions

## Prerequisites

- `kind` cluster running
- `kubectl` configured against the cluster
- Namespace `todoapp` and Deployment `todoapp` applied

## Steps

1. **Apply the RBAC manifests:**
   ```bash
   kubectl apply -f .infrastructure/security/rbac.yml
   ```

2. **Verify the ServiceAccount exists:**
   ```bash
   kubectl get sa secrets-reader -n todoapp
   ```

3. **Verify the Role exists:**
   ```bash
   kubectl get role secret-reader -n todoapp
   ```

4. **Verify the RoleBinding exists:**
   ```bash
   kubectl get rolebinding secret-reader-binding -n todoapp
   ```

5. **List secrets from the Deployment pod using the ServiceAccount:**
   ```bash
   kubectl exec -n todoapp deploy/todoapp -- curl -s \
     --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
     -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
     https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
   ```

6. **Take a screenshot** of the output showing the secrets list response and attach it to your PR.

> **Note:** The Deployment (`.infrastructure/app/deployment.yml`) already uses `serviceAccountName: secrets-reader`. No changes needed there.

### Screenshot

Paste your screenshot here:

![RBAC secrets list](./screenshots/rbac-secrets-list.png)
