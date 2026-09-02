# INSTRUCTION

## 1. Create cluster

```bash
kind create cluster --config cluster.yml
```

## 2. Deploy application

```bash
./bootstrap.sh
```

## 3. Check RBAC

```bash
kubectl get serviceaccount -n todoapp
kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
```

## 4. Check permissions

```bash
kubectl auth can-i list secrets --as=system:serviceaccount:todoapp:secrets-reader -n todoapp
```

Expected:

```text
yes
```

## 5. Get Pod

```bash
POD=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath="{.items[0].metadata.name}")
```

## 6. List Secrets from Pod

```bash
kubectl exec -n todoapp "$POD" -- sh -c 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); curl -k -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
```

Expected response contains:

```text
"kind":"SecretList"
```
