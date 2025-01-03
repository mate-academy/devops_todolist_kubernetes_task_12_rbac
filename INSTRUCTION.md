https://ibb.co/6WFSdHN
https://ibb.co/YDQcNd0


kind delete cluster
kind create cluster --config cluster.yml
kind create ns todoapp
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl exec -it <pod_name> -n todoapp -- sh
curl -sSk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets