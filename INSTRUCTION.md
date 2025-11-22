First - create cluster:

kind create cluster --config cluster.yml

after that run bootstrap.sh

than apply rbac.yml:

kubectl apply -f .infrastructure/security/rbac.yml

wait when pods will be ready:

kubectl get pods -n todoapp

after that connect to the pod:

kubectl exec -it {pod name} -n todoapp -- sh

inside the pod:

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secret

after that you can be sure that your rbac works correctly