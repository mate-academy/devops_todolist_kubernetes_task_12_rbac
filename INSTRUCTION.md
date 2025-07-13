apply manifests
kubectl apply -f security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml

Get into pod

kubectl get pods (for pod name)

kubectl exec -it <pod name> -- sh

Use curl
curl -s --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  https://kubernetes.default.svc/api/v1/secrets