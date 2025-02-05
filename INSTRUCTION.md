
## deploy application:
To deploy application run `./bootstrap.sh`

# getting secrets from pod:
1. Get pod name by `kubectl get pods -n todoapp`
2. Connect to pod `kubectl exec -it {pod_name} -n todoapp -- sh`
3. execute curl `curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr -d '\n')" -X GET https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets`