# RBAC Validation Instructions
## Prerequisites
- kind installed
- kubectl installed


## Setup
1. Create kind cluster:
```bash
kind create cluster --name todoapp-cluster --config cluster.yml

Create namespace:

kubectl create namespace todoapp

Apply RBAC manifest:

kubectl apply -f .infrastructure/security/rbac.yml

Apply deployment:

kubectl apply -f .infrastructure/app/deployment.yml
Validation

Wait for pod to be ready:

kubectl get pods -n todoapp -w

Get running pod name:

kubectl get pods -n todoapp -l app=todoapp --field-selector=status.phase=Running

Exec into pod and list secrets:

kubectl exec -n todoapp <pod-name> -- sh -c 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); curl -s -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
Expected: JSON response with secrets list.
Cleanup
kind delete cluster --name todoapp-cluster