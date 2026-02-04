# Validation Instructions

These steps validate the RBAC changes and the ability of the app pod to list secrets.

1. Deploy all required resources:

   ```
   kubectl apply -f .infrastructure/app/ns.yml
   kubectl apply -f .infrastructure/mysql/
   kubectl apply -f .infrastructure/app/
   kubectl apply -f .infrastructure/security/rbac.yml
   ```

2. Wait for MySQL and the app to be ready:

   ```
   kubectl get pods -n mysql
   kubectl get pods -n todoapp
   ```

   Ensure `mysql-0` and `mysql-1` are `Running`, and at least one `todoapp` pod is `Running`.

3. Exec into an app pod:

   ```
      POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
      kubectl exec -it $POD_NAME -n todoapp -- sh
   ```

4. Run command to take a json with secrets

   ```
   APISERVER=https://kubernetes.default.svc
   SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
   TOKEN=$(cat ${SERVICEACCOUNT}/token)
   CACERT=${SERVICEACCOUNT}/ca.crt
   curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
   ```

5. Expected result: The API should return a JSON list of secrets in `todoapp`
