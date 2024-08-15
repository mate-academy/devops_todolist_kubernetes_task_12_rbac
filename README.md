# Apply cluster

kind create cluster --config .infrastructure/app/cluster.yml

# Apply all manifests

sh bootstrap.sh

# Verify updated information

kubectl exec <the pod you want to check> -it -n todoapp -- sh

# Paste inside pod shell

APISERVER=https://kubernetes.default.svc
SERVICEAC# COUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SE# # RVICEACCOUNT}/ca.crt

# Run the command that lists the secrets

curl -s --cacert ${CACERT} --header "Authorization: Bearer $TOKEN" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
