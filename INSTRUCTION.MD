# RBAC for TodoApp

## 1. Create a Kubernetes cluster:
```bash
kubectl create cluster --config cluster.yml
```

## 2. Deploy the application and additional resources:
```bash
./bootstrap.sh
```

## 3. Wait for 1-2 minutes for all pods to initialize. Once ready, verify the pod statuses:
```bash
kubectl get pods -n todoapp
```

## 4. Connect to a pod:
```bash
kubectl exec <pod name> -it -n todoapp -- sh
```

## 5. Set Up and Execute the cURL Command:
```bash
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

## 6. Verify the Output.
The response should include the details of the secrets in the todoapp namespace.
