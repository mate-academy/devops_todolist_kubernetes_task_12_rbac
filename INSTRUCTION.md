kind create cluster --name todoapp --config cluster.yml
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml


# Get the pod name
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for=condition=ready pod/$POD_NAME -n todoapp --timeout=120s

kubectl get sa -n todoapp
kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
kubectl get deploy -n todoapp

# Exec into the pod and run the correct curl command
kubectl exec -it $POD_NAME -n todoapp -- /bin/sh -c
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) && \
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt && \
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace) && \
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/secrets
