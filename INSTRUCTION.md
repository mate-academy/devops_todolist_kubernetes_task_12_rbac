# Validation Instructions

This document describes how to validate the RBAC configuration.

## Prerequisites

Ensure the Kubernetes cluster is running and all required manifests are available.

## Validation Steps

1. Apply all Kubernetes manifests:

   ```bash
   kubectl apply -f .infrastructure/app/ns.yml
   kubectl apply -f .infrastructure/security/rbac.yml
   kubectl apply -f .infrastructure/app/secret.yml
   kubectl apply -f .infrastructure/app/configMap.yml
   kubectl apply -f .infrastructure/app/pvc.yml
   kubectl apply -f .infrastructure/app/pv.yml
   kubectl apply -f .infrastructure/app/deployment.yml
   ```

2. Get the name of the running pod:

   ```bash
   kubectl get pods -n todoapp
   ```

3. Open a shell inside the application pod:

   ```bash
   kubectl exec -it <pod-name> -n todoapp -c todoapp -- sh
   ```

4. From inside the pod, use the ServiceAccount token to query the Kubernetes API for secrets:

   ```bash
   TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

   curl -k \
     -H "Authorization: Bearer $TOKEN" \
     https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
   ```

## Expected Result

The request must fail and return a `403 Forbidden` response similar to:

```json
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "secrets is forbidden: User \"system:serviceaccount:todoapp:pods-lister\" cannot list resource \"secrets\" in API group \"\" in the namespace \"todoapp\"",
  "reason": "Forbidden",
  "details": {
    "kind": "secrets"
  },
  "code": 403
}
```

This confirms that the `pods-lister` ServiceAccount is correctly restricted by the RBAC configuration and cannot access Secrets in the `todoapp` namespace.