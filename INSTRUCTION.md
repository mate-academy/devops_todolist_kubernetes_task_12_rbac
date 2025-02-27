### Execute script
```bash
 chmod +x bootstrap.sh
./bootstrap.sh
```
### Verify pod statuses
```bash
 kubectl get pods -n todoapp
```

```bash
 kubectl exec <pod_name> -it -n todoapp -- sh
```

### Set up env
```bash
 SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
```

### Execute command
```bash
 curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```