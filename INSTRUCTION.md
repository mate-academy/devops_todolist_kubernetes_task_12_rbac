# Validation Instructions for RBAC Setup and Deployment

This document describes how to validate the RBAC configuration and deployment for the `todoapp` namespace.

---

## Prerequisites

- You have `kubectl` installed and configured.
- You have access to the Kubernetes cluster created by `kind` or other means.
- Your manifests are located in the `.infrastructure` directory with the following structure:
  - `.infrastructure/security/rb`
  - `.infrastructure/app/deployment.yml`
  - `cluster.yml` for kind cluster configuration

---

## Steps to Validate

1. **Create the cluster with kind**

   ```bash
   kind create cluster --config cluster.yml
   ```

2. **Apply manifests**

   Apply the RBAC manifests:

   ```bash
   kubectl apply -f .infrastructure/security/rbac.yml
   ```

   Apply the application deployment manifest:

   ```bash
   kubectl apply -f .infrastructure/app/deployment.yml
   ```

3. **Verify resources**

   Check that the `todoapp` namespace exists and pods are running:

   ```bash
   kubectl get namespaces
   kubectl get pods -n todoapp
   ```

4. **Verify ServiceAccount and RoleBinding**

   ```bash
   kubectl get serviceaccount secrets-reader -n todoapp
   kubectl get rolebinding secrets-reader-binding -n todoapp
   ```

5. **Exec into a running pod and list secrets**

   Find a pod name in the `todoapp` namespace:

   ```bash
   kubectl get pods -n todoapp
   ```

   Execute the following command, replacing `<pod-name>` with your pod name:

   ```bash
   kubectl exec -n todoapp -it <pod-name> -- sh -c "curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
     -H \"Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\" \
     https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets"
   ```

   You should see a JSON response listing the secrets in the `todoapp` namespace.

---

## Notes

- The deployment must use the `secrets-reader` ServiceAccount.
- The Role must allow listing and getting secrets.
- The RoleBinding must bind the Role to the ServiceAccount in the `todoapp` namespace.

# End of Instructions
