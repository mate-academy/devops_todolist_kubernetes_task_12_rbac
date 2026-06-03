## Cluster Deployment and RBAC Testing Guide

1. Deploying a local cluster

Start creating a kind cluster based on the existing cluster.yml configuration file:
```bash
kind create cluster --config cluster.yml
```
2. Deploying the application infrastructure

Run the script to automatically deploy the MySQL database, TodoApp, and the required ConfigMaps, Secrets, and PVCs:
```bash
bash .infrastructure/deploy.sh
```
3. Applying Security Settings (RBAC)

Use the manifest to create a ServiceAccount, Role, and RoleBinding in the todoapp namespace:
```bash
kubectl apply -f security/rbac.yaml
```

4. Linking the ServiceAccount to the Application

Make sure the spec.template.spec section of the deployment.yaml file specifies the line serviceAccountName: pods-lister, and apply the changes:
```bash
kubectl apply -f deployment.yaml
```

5. Checking Permissions and Access Validation (Testing)

To confirm that the created ServiceAccount has successfully gained read access to secrets, connect interactively to the pod and send a request to the Kubernetes API server:
```bash
kubectl get pods -n todoapp
kubectl exec -it ИМЯ_ПОДА -n todoapp -- /bin/sh
curl -k -v [https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets](https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets) \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
```
