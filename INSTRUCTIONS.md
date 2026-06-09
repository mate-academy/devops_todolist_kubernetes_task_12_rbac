# Validation Instructions
## Prerequisites
- Python 3.8+
- Docker
- kind
- kubectl


## Setup
1. **Create kind cluster:**
   ```bash
   kind create cluster --config cluster.yml
2. **Apply RBAC manifest:**
   ```bash    
    kubectl apply -f security/rbac
3. **Apply deployment:**
   ```bash
   kubectl apply -f deployment/

4. **Wait for pod to be ready:**
   ```bash
   kubectl get pods -n mateapp -w


## Validation
1. **Get pod name:**
   ```bash
   kubectl get pods -n mateapp
2. **Exec into pod and list secrets:**
   ```bash
   kubectl exec -it <pod-name> -n mateapp -- sh
   curl -k https://kubernetes.default/api/v1/namespaces/mateapp/secrets


