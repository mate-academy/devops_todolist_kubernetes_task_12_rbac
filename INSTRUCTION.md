# Validation Guide

## Prerequisites

- Docker
- kind
- kubectl

## 1. Create a kind cluster

```bash
kind create cluster --name todo-rbac --config cluster.yml
kubectl config use-context kind-todo-rbac
```

## 2. Deploy infrastructure manifests

```bash
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/hpa.yml
```

Wait until pods are ready:

```bash
kubectl get pods -n mysql -w
kubectl get pods -n todoapp -w
```

## 3. Validate RBAC resources

```bash
kubectl get sa rbac-sa -n todoapp
kubectl get role rbac-role -n todoapp
kubectl get rolebinding rbac-rolebinding -n todoapp
```

Check that `Role` includes permissions to list secrets:

```bash
kubectl get role rbac-role -n todoapp -o yaml
```

Expected in `rules`:

- `resources: ["secrets"]`
- `verbs: ["list"]` (or `["get","list"]`)

## 4. Validate Deployment uses the new ServiceAccount

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

Expected output:

```text
rbac-sa
```

## 5. Execute curl from Deployment pod to list secrets

Get one app pod name:

```bash
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
echo "$POD_NAME"
```

Run request to Kubernetes API from inside the pod:

```bash
kubectl exec -n todoapp "$POD_NAME" -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
curl -sS --cacert "$CACERT" -H "Authorization: Bearer $TOKEN" \
  "https://kubernetes.default.svc/api/v1/namespaces/$NS/secrets"
'
```

Expected result:

- Response contains `"kind":"SecretList"` and list of secrets from `todoapp` namespace.

Take a screenshot of this command output and attach it to the PR.

## 6. Optional cleanup

```bash
kind delete cluster --name todo-rbac
```
