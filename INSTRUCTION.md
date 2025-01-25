# Validation Instructions

1. **Start the Kind cluster**:
```bash
   kind create cluster --config cluster.yml
```
2. Apply the manifests: Deploy the RBAC manifests and Deployment:
```bash
kubectl apply -f .infrastructure/security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml
```
3. Check the pods: Ensure that the pods are running:
```bash
kubectl get pods -n todoapp
```

4. Test access to secrets: Execute the following command inside the todoapp pod:
```bash
kubectl exec -it <pod-name> -n todoapp -- curl -s http://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  -H "Accept: application/json" \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```
Replace <pod-name> with the name of the pod. You should see a JSON response with the secrets list.

