kubectl apply ./infrastructure/ -R

kubectl exec todoapp-97868d467-nbgc5 -it -n todoapp -- sh
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} \
     --header "Authoriza> tion: Bearer ${TOKEN}" \
     -X GET https://kuber> netes.default.svc/api/v1/namespaces/${NAMESPACE}/secrets