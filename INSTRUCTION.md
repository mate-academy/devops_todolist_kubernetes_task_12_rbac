### How to validate the changes

#### Execute in your terminal

```bash
./bootstrap
kubectl apply -f security/rbac.yml 
kubectl apply -f .infrastructure/app/deployment.yml
```
#### Enter in your pod with app

```bash
kubectl get pod -n todoapp
kubectl exec <pod-name> -n todoapp -it -- sh
```
#### Execute in pod
```bash
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```