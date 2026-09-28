# Validation Instructions

1. Create the kind cluster:

   kind create cluster --config cluster.yml

2. Deploy the application infrastructure:

   bash bootstrap.sh

3. Apply the RBAC configuration:

   kubectl apply -f .infrastructure/security/rbac.yml

4. Verify that the ServiceAccount, Role, and RoleBinding were created:

   kubectl get serviceaccount,role,rolebinding -n todoapp

5. Check the application Pods and choose a running Pod:

   kubectl get pods -n todoapp

6. Open a shell inside the Pod (replace <pod-name> with the Pod name from the previous command):

   kubectl exec -it <pod-name> -n todoapp -- sh

7. Inside the Pod, get the ServiceAccount token:

   TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

8. Use the token to list Secrets through the Kubernetes API:

   curl -k \
     -H "Authorization: Bearer $TOKEN" \
     https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets

The request should succeed and return a SecretList containing the app-secret Secret.