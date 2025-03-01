# Instructions on how to validate the changes

## 1. Apply the RBAC manifest inside the security directory:
    - kubectl apply -f ./security/rbac.yml
## 2. Apply the Deployment manifest:
    - kubectl apply -f .infrastructure/app/deployment.yml
## 3. Get the pod name and enter a running pod:
    - kubectl get pods -n todoapp
    - kubectl exec <pod-name> -it -n todoapp -- sh
## 4. Set environment variables to make a request to the API server:
    - SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
      APISERVER=https://kubernetes.default.svc
      TOKEN=$(cat ${SERVICEACCOUNT}/token)
      CACERT=${SERVICEACCOUNT}/ca.crt
## 5. List secrets in the todoapp namespace:
    - curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
