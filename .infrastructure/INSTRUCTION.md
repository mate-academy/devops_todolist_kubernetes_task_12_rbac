1. **Create kind cluster:**
   ```bash
   kind create cluster --config cluster.yml
2. **Apply RBAC manifest:**
   ```bash    
    kubectl apply -f security/rbac.yml
3. **Apply deployment:**
   ```bash
   kubectl apply -f deployment/


## Validation
2. **Exec into pod and list secrets:**
   ```bash
   kubectl exec -it <pod-name> -n mateapp -- sh
   curl -k https://kubernetes.default/api/v1/namespaces/mateapp/secrets