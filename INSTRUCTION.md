# Managing RBAC

## Prerequisites
* `kind` cluster running
* Namespace `todoapp` and `mysql`

### Step 1: Apply all manifests:

```bash
# Create Cluster
kind create cluster --config cluster.yml

# Deploy `RBAC` (Service Account + Role = RoleBinding)
kubectl apply -f .infrastructure/security/rbac.yml

# Deploy resources for `todoapp` application
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/deployment.yml

# Deploy resources for `mssql` server
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml
```

### Step 2: Verify and validate the deployment works:

```bash
# Get pods for todoapp application
kubectl get pods -n todoapp

# Connect to the `todoapp` pod
kubectl exec -it <app-pod-name> -n todoapp -- sh

# Execute a curl command to list secrets from the Deployment pod to list secrets
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/${NAMESPACE}/secrets
```

### Output:

```
PS C:\MateAcademy\repositories\devops_todolist_kubernetes_task_12_rbac> kubectl get pods -n todoapp
NAME                       READY   STATUS    RESTARTS       AGE
todoapp-6f8f99b74f-ctmns   1/1     Running   3 (4m2s ago)   4m50s
PS C:\MateAcademy\repositories\devops_todolist_kubernetes_task_12_rbac> kubectl exec -it todoapp-6f8f99b74f-ctmns -n todoapp -- sh
# ls
Dockerfile  accounts  api  configs  data  lists  manage.py  probes  requirements.txt  secrets  todolist
# APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)# # # #
# curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/${NAMESPACE}/secrets
{
  "kind": "SecretList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "2190"
  },
  "items": [
    {
      "metadata": {
        "name": "app-secret",
        "namespace": "todoapp",
        "uid": "de6395c1-8a06-498c-8443-9cf59ba87e0b",
        "resourceVersion": "1231",
        "creationTimestamp": "2026-09-17T12:25:32Z",
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"data\":{\"DB_HOST\":\"bXlzcWwtMC5teXNxbC5teXNxbC5zdmMuY2x1c3Rlci5sb2NhbAo=\",\"DB_NAME\":\"YXBwX2RiCg==\",\"DB_PASSWORD\":\"MTIzNA==\",\"DB_USER\":\"YXBwX3VzZXI=\",\"SECRET_KEY\":\"QGUyKHl4KXYmdGdoM19zPTB5amEtaSFkcGVieHN6XmRnNDd4KS1rJmtxXzN6Zio5ZSoK\"},\"kind\":\"Secret\",\"metadata\":{\"annotations\":{},\"name\":\"app-secret\",\"namespace\":\"todoapp\"},\"type\":\"Opaque\"}\n"
        },
        "managedFields": [
          {
            "manager": "kubectl-client-side-apply",
            "operation": "Update",
            "apiVersion": "v1",
            "time": "2026-09-17T12:25:32Z",
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
```

Also attached screenshot by path `\output\managing_RBAC.png`.