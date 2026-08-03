# Instructions for checking changes made to the rbac

## Check if our role has been created
This command will show existing roles in namespace todoapp and will show our created role:
```bash
kubectl get roles -n todoapp
```

Detailed information about role permissions, you can see in PolicyRule: Resources - secrets and Verbs - [list get]:
```bash
kubectl describe role secrets-reader -n todoapp
```

## Check if our rolebinding has been created
This command will show existing rolebinding in namespace todoapp and will show our created rolebinding:
```bash
kubectl get rolebinding -n todoapp
```

## How to use our role to check secrets from the container
Use:
```bash
kubectl get pods -n todoapp
```
```bash
kubectl exec -it -n todoapp <pod-name> -- sh
```

Use variables in a container:
```bash
APISERVER=https://kubernetes.default.svc 
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount 
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
```
With this curl you will get the secret:
```bash
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```