1. Run scripts
./bootstrap.sh
2. After ingress deployment you should be able to access the app on http://localhost and see the app running.
Check all links what you see.
3. Inspect labels and taints:
Check labels, use command
kubectl get nodes --show-labels
If labels app=mysql and   not exists, use commands:
kubectl label nodes kind-worker kind-worker2 app=mysql
kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp

$POD_NAME = kubectl get pods -n todoapp -o jsonpath='{.items[0].metadata.name}'
kubectl exec $POD_NAME -it -n todoapp -- sh
run commands in pod terminal:
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets

You shoul see correct answer without error 403 Forbitten!
Something like that:
# curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
{
  "kind": "SecretList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "18681"
  },
  "items": [
    {
      "metadata": {
        "name": "app-secret",
        "namespace": "todoapp",
        "uid": "8868c7ce-b496-4774-bda5-96e00643873f",
        "resourceVersion": "686",
        "creationTimestamp": "2026-07-16T10:44:31Z",
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"data\":{\"DB_HOST\":\"bXlzcWwtMC5teXNxbC5teXNxbC5zdmMuY2x1c3Rlci5sb2NhbAo=\",\"DB_NAME\":\"YXBwX2RiCg==\",\"DB_PASSWORD\":\"MTIzNA==\",\"DB_USER\":\"YXBwX3VzZXI=\",\"SECRET_KEY\":\"QGUyKHl4KXYmdGdoM19zPTB5amEtaSFkcGVieHN6XmRnNDd4KS1rJmtxXzN6Zio5ZSoK\"},\"kind\":\"Secret\",\"metadata\":{\"annotations\":{},\"name\":\"app-secret\",\"namespace\":\"todoapp\"},\"type\":\"Opaque\"}\n"
        },
        "managedFields": [
          {
            "manager": "kubectl-client-side-apply",
            "operation": "Update",
            "apiVersion": "v1",
            "time": "2026-07-16T10:44:31Z",
            "fieldsType": "FieldsV1",
            "fieldsV1": {
              "f:data": {
                ".": {},
                "f:DB_HOST": {},
                "f:DB_NAME": {},
                "f:DB_PASSWORD": {},
                "f:DB_USER": {},
                "f:SECRET_KEY": {}
              },
              "f:metadata": {
                "f:annotations": {
                  ".": {},
                  "f:kubectl.kubernetes.io/last-applied-configuration": {}
                }
              },
              "f:type": {}
            }
          }
        ]
      },
      "data": {
        "DB_HOST": "bXlzcWwtMC5teXNxbC5teXNxbC5zdmMuY2x1c3Rlci5sb2NhbAo=",
        "DB_NAME": "YXBwX2RiCg==",
        "DB_PASSWORD": "MTIzNA==",
        "DB_USER": "YXBwX3VzZXI=",
        "SECRET_KEY": "QGUyKHl4KXYmdGdoM19zPTB5amEtaSFkcGVieHN6XmRnNDd4KS1rJmtxXzN6Zio5ZSoK"
      },
      "type": "Opaque"
    }
  ]
}#