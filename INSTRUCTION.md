1. Run scripts
kind create cluster --config cluster.yml
./bootstrap.sh
2. After ingress deployment you should be able to access the app on http://localhost and see the app running.
Check all links what you see.
3. Inspect labels and taints:
Check labels, use command
kubectl get nodes --show-labels
If labels app=mysql and   not exists, use commands:
kubectl label nodes kind-worker kind-worker2 app=mysql
kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp

$POD_NAME = kubectl get pods -n mateapp -o jsonpath='{.items[0].metadata.name}'
kubectl exec $POD_NAME -it -n mateapp -- sh
run commands in pod terminal:
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/mateapp/pods

You shoul see correct answer without error 403 Forbitten!