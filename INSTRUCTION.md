Preconditions
```bash
kind create cluster --config cluster.yml
./bootstrap.sh
kubectl apply -f .infrastructure/ingress/ingress.yml
```

Get pod name and connect to it
```bash
kubectl get pods -n todoapp
kubectl exec -it <pod_name> -n todoapp -- /bin/sh
```
save needed info to read secrets, execute in pod terminal
```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
API_URL="https://kubernetes.default.svc"
```
read secrets
```bash
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET $API_URL/api/v1/namespaces/todoapp/secrets
```