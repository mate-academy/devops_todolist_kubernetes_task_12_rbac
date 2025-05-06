# RBAC Task Instructions

##  Steps to Validate

1. Ensure kind cluster is running and all nodes are `Ready`.
2. Apply all necessary manifests:
   ```bash
   kubectl apply -f .infrastructure/app/
   kubectl apply -f .infrastructure/mysql/
   kubectl apply -f security/rbac.yml

   kubectl get pods -n todoapp

   kubectl -n todoapp exec -it curl -- sh

   curl -sSk \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets