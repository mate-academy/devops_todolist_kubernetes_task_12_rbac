# RBAC Verification Instructions

## Prerequisites
- Docker installed
- `kind` installed
- `kubectl` installed

## Steps

1. **Create a cluster**
```bash
kind create cluster --config cluster.yml
```

2. **Create a namespace (if one doesn't already exist) and apply the RBAC manifest**
```bash
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f security/rbac.yml
```

3. **Apply Deployment**
```bash
kubectl apply -f .infrastructure/deployment.yml -n todoapp
```

4. **Verify that ServiceAccount, Role and RoleBinding are created**
```bash
kubectl get serviceaccount secrets-reader-sa -n todoapp
kubectl get role secrets-reader -n todoapp
kubectl get rolebinding secrets-reader-binding -n todoapp
```

5. **Verify that the pod is using the correct ServiceAccount**
```bash
kubectl get pod -l app=todoapp -n todoapp -o jsonpath='{.items[0].spec.serviceAccountName}'
```
Expected result: `secrets-reader-sa`

6. **Run curl from inside the pod to get the list of secrets**
```bash
POD_NAME=$(kubectl get pod -l app=todoapp -n todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $POD_NAME -n todoapp -- curl -s \
-H "Authorization: Bearer $(kubectl exec $POD_NAME -n todoapp -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```
If RBAC is configured correctly, the response will be JSON with a list of secrets (HTTP 200),
not a `403 Forbidden` error.

7. **(Negative test)** Make sure there are no extra privileges:
```bash
kubectl auth can-i list secrets --as=system:serviceaccount:todoapp:secrets-reader-sa -n todoapp
# should return "yes"

kubectl auth can-i delete secrets --as=system:serviceaccount:todoapp:secrets-reader-sa -n todoapp
# should return "no"
```

## Expected result
- `kubectl get rolebinding -n todoapp` shows `secrets-reader-binding`.
- `curl` call to Kubernetes API from inside pod returns a list of secrets (200 OK).
- `kubectl auth can-i list secrets --as=... -n todoapp` returns `yes`.
- `kubectl auth can-i delete secrets --as=... -n todoapp` returns `no`.