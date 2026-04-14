To validate changes use command:

    To run infrastructure:

        bash ./bootstrap.sh

To check pods names:

    kubectl get pods -n todoapp

To go inside of pod:

    kubectl exec -it <pod_name> -n todoapp -- sh

Insede of pod use commands:

    APISERVER=https://kubernetes.default.svc
    SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
    TOKEN=$(cat ${SERVICEACCOUNT}/token)
    CACERT=${SERVICEACCOUNT}/ca.crt

    curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets