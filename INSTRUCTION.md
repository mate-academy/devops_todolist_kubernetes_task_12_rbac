How to validate the changes

# Create the kind cluster
From the repository root, run:

kind create cluster --config cluster.yml

# Expected result:
Set kubectl context to "kind-kind"
You can now use your cluster with:
kubectl cluster-info --context kind-kind

# To get roles and rolebindings you can use:

kubectl get roles -A
kubectl describe roles -n <namespace-name> <role-name>
kubectl get rolebindings -A
kubectl describe rolebindings -n <namespace-name> <rolebinding-name>

# To get clusterroles and clusterrolebindings you can use:

kubectl get clusterrole -A
kubectl describe roles <clusterrole-name>
kubectl get clusterrolebindings
kubectl describe clusterrolebindings <clusterrolebinding-name>

# To check our reader we need to connect to one of the pods:
kubectl get pods -n todoapp
kubectl exec <pod-name> -it -n todoapp -- sh

# Run:
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
