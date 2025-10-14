### 1. Create the cluster from config file:
```bash
kind create cluster --config cluster.yml
```

### 2. Run script to set up databases, apps, ingress, rbac:
```bash
./bootstrap.sh
```

### 3. Get the pod name to exec the command:
```bash
kubectl get pods -n todoapp
```

### 4. Validate rbac access to list the secrets
You do not need to receive 403 status code
```bash
kubectl exec -n todoapp -it <pod-name> -- sh
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount APISERVER=https://kubernetes.default.svc TOKEN=$(cat ${SERVICEACCOUNT}/token) CACERT=${SERVICEACCOUNT}/ca.crt curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```
You should NOT receive a 403; if you do, RBAC is misconfigured
