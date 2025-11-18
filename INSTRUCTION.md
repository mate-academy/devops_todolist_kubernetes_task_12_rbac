## Setup and Deployment

The bootstrap.sh script contains all the commands to create the KinD cluster, taint nodes, and deploy the MySQL
StatefulSet and todoapp Deployment with the required affinity and anti-affinity rules.

Run the following commands to initialize the KinD cluster and deploy all resources:

```bash
kind create cluster --name todoapp-cluster --config cluster.yml

./bootstrap.sh
```

## Verify RBAC Resources

1. Verify ServiceAccount

```bash
kubectl get serviceaccount -n todoapp
```

Expected result:

A ServiceAccount named secrets-reader should exist.

2. Verify Role

```bash
kubectl get role -n todoapp
kubectl describe role secrets-reader -n todoapp
```

Expected result:

The Role should contain a rule allowing:

```text
resources: ["secrets"]
verbs: ["list"]
```

3. Verify RoleBinding

```bash
kubectl get rolebinding -n todoapp
kubectl describe rolebinding secrets-reader-binding -n todoapp
```

Expected result:

The RoleBinding should bind:
Role: secrets-reader
ServiceAccount: secrets-reader

## Validate That The Pod Can List Secrets

Once the todoapp Pod is running, execute the following steps.

1. Get the Pod name:

```bash
kubectl get pods -n todoapp
```

2. Exec into the pod:

```bash
kubectl exec -it -n todoapp <todoapp-pod-name> -- sh
```

3. Run the curl command inside the pod:

```bash
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

curl -s \
  --cacert $CACERT \
  -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/$NAMESPACE/secrets
```

Expected Result

The output should be a JSON list of secrets from the todoapp namespace.
This proves:
✔ The ServiceAccount is used
✔ The Role allows listing secrets
✔ The RoleBinding correctly links them
✔ The Pod has sufficient permissions

## 🧹 Cleanup

When finished, delete the entire KinD cluster to clean up all resources (pods, services, volumes, etc.).

```bash
kind delete cluster --name todoapp-cluster
```
