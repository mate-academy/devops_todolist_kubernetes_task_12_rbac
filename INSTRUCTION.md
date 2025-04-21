# Validating RBAC in Django ToDo app
## Set up enviroment
```bash
./bootstrap.sh
```
## Validating changes
```bash
kubectl get pods -n todoapp
```
```bash
kubectl exec < pod-name > -it -n todoapp -- sh
```
Run this commands inside the shell

```bash
CACERT=${SERVICEACCOUNT}/ca.crt
```
```bash
TOKEN=$(cat ${SERVICEACCOUNT}/token)
```
```bash
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```
