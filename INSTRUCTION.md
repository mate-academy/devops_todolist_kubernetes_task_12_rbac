# RBAC Verification Instructions

This guide explains how to verify that the `todoapp` pod has the necessary permissions to list secrets within its namespace.

## Prerequisites
1. Apply the RBAC configuration:
   ```bash
   kubectl apply -f .infrastructure/security/rbac.yml

2. Update the deployment to use the new ServiceAccount:

kubectl apply -f .infrastructure/app/deployment.yml

3. ## Verification Command
Run the following command to test RBAC permissions:

```bash
kubectl exec -it <pod-name> -n todoapp -- bash

curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
[https://kubernetes.default.svc/api/v1/namespaces/$(cat](https://kubernetes.default.svc/api/v1/namespaces/$(cat) /var/run/secrets/kubernetes.io/serviceaccount/namespace)/secrets