Create cluster with kind:
```
kind create clusters --config cluster.yml
```
Grant permissions to execute to file and execute script bootstrap.sh

Wait untill pods of todoapp are started. Check periodically:
```
kubectl get pods -n todoapp
```

Grab the name of one of the pods with todoapp and execute:

```
kubectl exec todoapp-<namepart> -it  -n todoapp  -- sh
```

Now bind variables:
```
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
````

The output must contain the secrets like on the screenshot attached.