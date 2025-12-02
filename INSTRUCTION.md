# How to validate the solution

## 1. Create kind cluster

```bash
kind delete cluster --name todolist || true
kind create cluster --name todolist --config cluster.yml

# Make sure kubectl is configured to use this cluster:
kubectl cluster-info

# Deploy application and RBAC
# From the repository root:
./bootstrap.sh

# Wait until all pods are running:
kubectl get pods -A
kubectl get pods -n todoapp
kubectl get pods -n mysql

# Check RBAC objects
kubectl get serviceaccount secrets-reader -n todoapp
kubectl get role secrets-reader -n todoapp
kubectl get rolebinding secrets-reader -n todoapp

# List secrets from inside the Deployment pod
# Get the name of one todoapp pod:
POD_NAME=$(kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
echo $POD_NAME

# Execute a curl command inside this pod to list secrets in the todoapp namespace:
kubectl exec -n todoapp "$POD_NAME" -- sh -c '
  curl --silent \
    --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets