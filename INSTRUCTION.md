# Kubernetes RBAC Task

## 1. Apply all manifests

```bash
bash bootstrap.sh
```

## 2. Verify ServiceAccount

```bash
kubectl get sa -n todoapp
```

Expected output should include:

```text
secrets-listener
```

## 3. Verify Role and RoleBinding

```bash
kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
```

Expected output should include:

```text
secrets-listener
secrets-listener-binding
```

## 4. Verify Deployment Uses ServiceAccount

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'
```

Expected output:

```text
secrets-listener
```

## 5. Verify Secret Listing Permission

Get the pod name:

```bash
kubectl get pods -n todoapp
```

Execute:

```bash
kubectl exec -it -n todoapp <pod-name> -- sh
```

Inside the pod:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl -s \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```

Expected result: a JSON response containing the list of secrets in the `todoapp` namespace.
