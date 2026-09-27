To create all dependencies run:
```
chmod +x bootstrap.sh
./bootstrap.sh
```

To curl app and list secrets with other user:
```
kubectl get pods -n todoapp
kubectl exec -it {pod_with_app} -n todoapp -- sh

# inside pod
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```
