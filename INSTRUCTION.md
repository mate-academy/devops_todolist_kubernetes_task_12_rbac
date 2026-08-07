# Validation Instructions for Kubernetes RBAC Configuration

This document provides step-by-step instructions to validate the RBAC configuration, ServiceAccount bindings, and API access for listing secrets.

---

## 1. Apply Infrastructure and Security Manifests

Deploy the namespace, RBAC rules, secrets, and application deployment:

```bash
# Apply app resources
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml

# Apply RBAC rules
kubectl apply -f .infrastructure/security/rbac.yml

# Apply deployment using the new ServiceAccount
kubectl apply -f .infrastructure/app/deployment.yml
```

## 2. Validate RBAC Resources
Verify that the ServiceAccount, Role, and RoleBinding are created in the todoapp namespace:

```Bash
kubectl get serviceaccount,role,rolebinding -n todoapp
```

## 3. Validate Pod ServiceAccount Usage
Verify that the running pod uses the secrets-reader ServiceAccount:

```Bash
kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].spec.serviceAccountName}'
```
Expected Output: secrets-reader

## 4. Test API Access from Inside the Pod
Execute the curl request to the Kubernetes API server from within the application pod using its ServiceAccount token:

```Bash
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it -n todoapp $POD_NAME -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl --cacert $CACERT -H "Authorization: Bearer $TOKEN" [https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets](https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets)
'
```

Expected Output: A JSON response with "kind": "SecretList" containing the app-secret object.