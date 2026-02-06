# RBAC Validation Guide

To validate that the Pod has permissions to list secrets via ServiceAccount:

1. **Deploy the stack:**
   ```bash
   ./bootstrap.sh
2. Wait for the Pod to be ready:

```
kubectl get pods -n mateapp
```
3. Execute the validation command: Replace <POD_NAME> with the actual pod name:

```
kubectl exec -it <POD_NAME> -n mateapp -- /bin/sh -c 'curl -s -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" [https://kubernetes.default.svc/api/v1/namespaces/mateapp/secrets](https://kubernetes.default.svc/api/v1/namespaces/mateapp/secrets)'
```
4. Expected Output: You should see a JSON response with "kind": "SecretList".