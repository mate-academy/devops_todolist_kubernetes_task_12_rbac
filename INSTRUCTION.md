## Steps to Validate

1. Create the Kubernetes cluster using kind:
   ```bash
   kind create cluster --config cluster.yml
   ```

2. Apply the RBAC configuration:
   ```bash
   kubectl apply -f security/rbac.yaml
   ```

3. Verify the ServiceAccount, Role, and RoleBinding were created:
   ```bash
   kubectl get serviceaccount secret-reader
   kubectl get role secret-reader-role
   kubectl get rolebinding secret-reader-binding
   ```

4. Create a test pod using the ServiceAccount:
   ```bash
   kubectl run test-pod --image=curlimages/curl --serviceaccount=secret-reader -- sleep infinity
   ```

5. Wait for the pod to be running:
   ```bash
   kubectl wait --for=condition=Ready pod/test-pod
   ```

6. Execute the curl command to list secrets:
   ```bash
   kubectl exec test-pod -- curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/secrets
   ```

7. Clean up:
   ```bash
   kubectl delete pod test-pod
   kind delete cluster
   ```

## Expected Results
- The ServiceAccount, Role, and RoleBinding should be created successfully
- The test pod should be able to list secrets using the provided ServiceAccount
- The curl command should return a JSON response containing the list of secrets in the default namespace
