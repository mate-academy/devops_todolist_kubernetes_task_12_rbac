### Resource check

kubectl get serviceaccount secret-listener -n todoapp
kubectl get role secret-listener -n todoapp -o yaml
kubectl get rolebinding secret-listener-binding -n todoapp -o yaml

###  Deployment use valid ServiceAccount:
kubectl get deploy todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'

expected answer - secrets-reader

### Get pod name
kubectl get pods -n todoapp

execute command

kubectl exec -n todoapp <pod_name> -- \
sh -c 'curl -s --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets \
--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | jq .'