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

The request must succeed and return an HTTP `200 OK` status along with a JSON response listing the Secrets in the `todoapp` namespace.

Example response:

```json
{
  "kind": "SecretList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "12345"
  },
  "items": [
    {
      "metadata": {
        "name": "app-secret",
        "namespace": "todoapp"
      },
      "type": "Opaque",
      "data": {
        "DB_PASSWORD": "...",
        "SECRET_KEY": "..."
      }
    }
  ]
}
```

This confirms that the `pods-lister` ServiceAccount is correctly bound to the Role and has permission to list Secrets in the `todoapp` namespace.