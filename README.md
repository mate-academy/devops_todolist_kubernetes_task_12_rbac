# Deployment Guide
1. **Create cluster**
    ```sh
    kind create cluster --config cluster.yml
    ```

2. **Apply all manifests**
    ```sh
    ./bootstrap.sh
    ```

## Verification

1. **Check pods**
    ```sh
    kubectl get pods -n todoapp
    kubectl get pods -n mysql
    kubectl get pods -n ingress-nginx
    ```

2. **Check logs**
    ```sh
    kubectl logs <name_of_pod> -n <namespace>
    ```

3. **Check browser**
    ```sh
    http://localhost/
    ```

4. **Connect to one of the running pods**
    ```sh
    kubectl exec -it <one of running pod name> -n todoapp -- sh
    ```

5. **Create variables inside of the running pod**
    ```sh
    APISERVER=https://kubernetes.default.svc
    SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
    TOKEN=$(cat ${SERVICEACCOUNT}/token)
    CACERT=${SERVICEACCOUNT}/ca.crt
    ```

6. **Curl request**
    ```sh
    curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
    ```