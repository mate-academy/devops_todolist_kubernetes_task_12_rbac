# Instructions for Validation

1. **Set up the Cluster**:
   - Spin up a cluster using the `cluster.yml` configuration file:
     ```bash
     kind create cluster --config cluster.yml
     ```

2. **Deploy Resources**:
   - Apply the necessary Kubernetes resources:
     ```bash
     ./bootstrap.sh
     ```

3. **Verify ServiceAccount and Role**:
   - Ensure that the `secrets-reader` ServiceAccount and `secrets-reader-role` Role are created correctly.
   - Verify the RoleBinding is applied:
     ```bash
     kubectl get rolebinding secrets-reader-binding -n todoapp
     ```

4. **Check Secrets Access**:
   - Use the curl command to confirm that the Deployment pod can list secrets:
     ```bash
     kubectl run -i --tty --rm debug --serviceaccount secrets-reader --image=busybox --namespace todoapp -- curl -s localhost:8080/api/secrets
     ```

5. **Take a Screenshot**:
   - Take a screenshot of the `curl` command output and include it in your PR for validation.
