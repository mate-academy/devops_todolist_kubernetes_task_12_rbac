# RBAC for TodoApp

## 1. Create a kubernetes cluster using kind:

```bash
kind create cluster --config cluster.yml
```

## 2. Deploy the application and additional resources:
```bash
./bootstrap.sh
```

## 3. Wait for 2 minutes for all pods to initialize. Once ready, verify pods status:
```bash
kubectl get pods -n todoapp --context kind-kind
```
If this command does not show you information about your pods, try verifing cluster name using command:
```bash
kubectl config current-context
```
and replace 'kind-kind' with your context

## 4. Connect to a pod:
Replace <pod name> with your pod name
```bash
kubectl exec -n todoapp <pod name> -it -- sh
```

## 5. Set Up and Execute the CURL Command:
```bash
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

## Verify the Output:
The response should include the details of the secrets in the todoapp namespace.
