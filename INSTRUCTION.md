# Deploying and Installing the ToDo Application in a Kubernetes Cluster Using RBAC to Manage Secrets.

## Prerequisites:
 * Installed Docker Descktop

To get started, you need to set up a cluster:

```
kind create cluster --config cluster.yml --name cluster
```

All the necessary components are installed by a script:
```
bash bootstrap.sh
```

Manifesto Role-Based Access Control is launched with the command:
```
kubectl apply -f .infrastructure/security/rbac.yml
```

Once the deployment pods have reached the "Running" status, run the following command to check the availability of the secrets:
```
kubectl exec -n todoapp deploy/todoapp -- sh -c '
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  "https://kubernetes.default.svc/api/v1/namespaces/$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)/secrets"
'
```
_As a result of the command's output, you'll be able to see the secrets._

After all checks are complete, you can delete the cluster using the command:
```
kind delete cluster --name cluster
```