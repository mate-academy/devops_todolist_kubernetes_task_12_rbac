# How to validate the changes:
# Deploy the resources:
./bootstrap.sh
# How to apply RBAC:
kubectl apply -f rbac.yml
# How to validate changes:
kubectl get pods -n todoapp
kubectl exec <pod_name> -it -n todoapp -- bash
# after that in the middle of the container to perform:
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets