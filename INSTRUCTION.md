### 1. Create new cluster from config:
```angular2html
kind create cluster --config cluster.yaml
```
### 2. Run bootstrap.sh for deploy todoapp
### 3. To validate properly set-up rbac: 
Get in shell of one running pods from deployment
```angular2html
kubectl get pods -n todoapp
```

```angular2html
kubectl exec [name_of_pod] -it -n todoapp -- sh
```

And in shell run following commands:
```angular2html
# APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

You must get proper response with secrets from API-server instead of 403 Response Forbidden