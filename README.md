## To validate changes
Spin up a cluster from a `cluster.yml`

    kind create cluster --config cluster.yml

aplly all manifests

    sh bootstrap.sh

apply rbac.yml and deployment.yml

    kubectl.exe apply -f .infrastructure/security/rbac.yml
    kubectl.exe apply -f .infrastructure/app/deployment.yml

open created pods

    kubectl exec <pods name> -it -n todoapp -- sh

apply next command

    APISERVER=https://kubernetes.default.svc
    SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
    TOKEN=$(cat ${SERVICEACCOUNT}/token)
    CACERT=${SERVICEACCOUNT}/ca.crt

and check our secrets

    curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
