## 1. Environment setup
To prepare the cluster environment, follow these steps:
1. Spin up the Kubernetes cluster:
```bash
kind cluster create --config cluster.yml
```
2. Bootstrap the infrastructure:
Execute the bootstrap script to deploy all necessary resources:
```bash
./bootstrap.sh
```
## 2. RBAC Setup for secrets-reader
Verify that the secrets-reader ServiceAccount has the correct permissions:

1. Check ServiceAccount tokens:
```bash
kubectl describe serviceaccount secrets-reader -n todoapp
```
Expected: The Tokens field should list secrets-reader-token.

2. Verify Roles and Bindings:
Ensure the secret-reader-role is correctly bound to the secrets-reader account:
```bash
kubectl describe rolebinding bind-secret-reader -n todoapp
```

## 3. Validation
To verify the actual permission, execute the following commands inside one of the pods in the todoapp namespace:

1. Enter the pod:
```bash
kubectl exec -it <pod-name> -n todoapp -- /bin/sh
```
2. Run the validation script:
```bash
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" \
     -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```
## 4. Cleanup
To remove the environment after validation:
```bash
kind delete cluster
```


