# Validation Instructions

1. Create the kind cluster:

   ```bash
   kind create cluster --config cluster.yml
   ```

2. Deploy the infrastructure (this also applies `security/rbac.yml`):

   ```bash
   bash bootstrap.sh
   ```

3. Verify that the ServiceAccount, Role, and RoleBinding were created:

   ```bash
   kubectl get serviceaccount,role,rolebinding -n todoapp
   ```

4. Check that the Deployment uses the `secrets-reader` ServiceAccount:

   ```bash
   kubectl get deployment -n todoapp -o jsonpath='{.items[*].spec.template.spec.serviceAccountName}'
   ```

5. Wait for the Pods to be running and choose one:

   ```bash
   kubectl get pods -n todoapp
   ```

6. Open a shell inside the Pod (replace `<pod-name>` with the Pod name from the previous command):

   ```bash
   kubectl exec -it <pod-name> -n todoapp -- sh
   ```

7. Inside the Pod, get the ServiceAccount token:

   ```bash
   TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
   ```

8. Use the token to list Secrets through the Kubernetes API:

   ```bash
   curl -k \
     -H "Authorization: Bearer $TOKEN" \
     https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
   ```

   The request should succeed and return a `SecretList` containing the `app-secret` Secret.
