# Validation Instructions (Task 12: RBAC)

## 1. Deploy Environment
Run the bootstrap script to create the ServiceAccount and update the Deployment.
```bash
sh bootstrap.sh
```
# 2. Validate Service Account Injection

Verify that the Pod uses the correct ServiceAccount.
```bash
kubectl get pods -n todoapp -o yaml | grep serviceAccountName
```

Expected Output: serviceAccountName: todoapp-sa

# 3. Verify Access to Secrets (The Screenshot Task)

To verify that RBAC works, we will execute a command inside the Pod to try and list Kubernetes secrets via the API.

1. Get the Pod Name:
```bash
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath="{.items[0].metadata.name}")
```
2. Execute Curl Command: Run this command to use the internal ServiceAccount token to call the K8s API:

```bash
kubectl exec $POD_NAME -n todoapp -- sh -c 'curl -k -s -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'
```
Expected Output: You should see a JSON response containing a list of secrets (like todoapp-db-secret, default-token-xxxxx, etc.).

If RBAC was NOT working, you would get a "403 Forbidden" error.