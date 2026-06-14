1. **Create kind cluster:**
   ```bash
   kind create cluster --config cluster.yml
   ```
2. **Apply RBAC manifest:**
   ```bash    
    kubectl apply -f .infrastructure/security/rbac.yml
   ```
3. **Apply deployment:**
   ```bash
   kubectl apply -f .infrastructure/app/deployment.yml
   ```


## Validation
1. **Connect into pod**
      ```bash
   kubectl exec -it <pod-name> -n todoapp -- sh
   ```
2. **Exec into pod and list secrets:**
   ```bash
   APISERVER=https://kubernetes.default.svc
   SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
   TOKEN=$(cat ${SERVICEACCOUNT}/token)
   CACERT=${SERVICEACCOUNT}/ca.crt
   curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
   ```