# Validation Instructions

This document provides step-by-step instructions to validate the RBAC configuration and secret listing functionality in the TodoApp Kubernetes deployment.

## Prerequisites

- `kind` cluster running
- `kubectl` configured to connect to the cluster
- TodoApp deployed with the RBAC configuration

## Validation Steps

### 1. Verify RBAC Resources

Check that all RBAC components are created:

```bash
# Verify ServiceAccount
kubectl get serviceaccount secrets-lister -n todoapp

# Verify Role
kubectl get role secrets-lister -n todoapp

# Verify RoleBinding
kubectl get rolebinding secrets-lister-binding -n todoapp
```

### 2. Verify Deployment Configuration

Confirm the deployment is using the correct ServiceAccount:

```bash
# Check deployment uses the ServiceAccount
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'
```

Expected output: `secrets-lister`

### 3. Verify Pod is Running

```bash
# Get pod status
kubectl get pods -n todoapp -l app=todoapp

# Get pod name for further testing
export POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
```

### 4. Test Secret Listing Permissions

Execute curl command from the pod to list secrets:

```bash
# Test listing secrets using Kubernetes API
kubectl exec -n todoapp $POD_NAME -- curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

### 5. Alternative Testing Method

If curl is not available in the container, test permissions using kubectl:

```bash
# Test permissions using kubectl auth can-i
kubectl auth can-i list secrets --as=system:serviceaccount:todoapp:secrets-lister -n todoapp
kubectl auth can-i get secrets --as=system:serviceaccount:todoapp:secrets-lister -n todoapp
```

Expected output: `yes` for both commands

### 6. Verify Secret Access

Check that the pod can access the mounted secrets:

```bash
# Verify secret is mounted and accessible
kubectl exec -n todoapp $POD_NAME -- ls -la /app/secrets/

# Check environment variables from secrets
kubectl exec -n todoapp $POD_NAME -- env | grep -E "(SECRET_KEY|DB_)"
```

## Expected Results

1. All RBAC resources should be created successfully
2. Pod should be running with `secrets-lister` ServiceAccount
3. Curl command should return JSON response with secrets list
4. `kubectl auth can-i` commands should return `yes`
5. Secret files should be visible in `/app/secrets/` directory
6. Environment variables should be populated from secrets
