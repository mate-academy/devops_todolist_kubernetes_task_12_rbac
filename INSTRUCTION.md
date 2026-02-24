kind create cluster --config cluster.yml
# if file cluster.yml in your current directory

bash bootstrap.sh

kubectl get pods -n todoapp -l app=todoapp
# copy 1 of 2 pods name

kubectl get sa secrets-reader -n todoapp
kubectl get role pod-secrets-reader -n todoapp
kubectl get rolebinding pod-secrets-reader-binding -n todoapp
# check created sa,role,rolebinding


kubectl exec -it <copied-pods-name>  -n todoapp -- sh
# go in container

# RUN commands in container to get secrets
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} -H "Authorization: Bearer $TOKEN" ${APISERVER}/api/v1/namespaces/todoapp/secrets
# Take a screenshot of the curl output showing the secrets, attach the image to your PR, and paste the PR link in your submission so validators can access it.