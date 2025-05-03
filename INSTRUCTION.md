# Instructions to Validate the Changes

## 1. Deployment the all resources
Run the `bootstrap.sh` script to deploy all necessary manifests
## 2. Verify the changes
- Check if the application pod is running:
`kubectl get pods -n todoapp`
- Find the name of the running pod and open a shell inside it:
`kubectl exec -it <todoapp-pod-name> -n todoapp -- sh`
- Once inside the pod, run the following to attempt accessing resources from the todoapp namespace:
```
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

