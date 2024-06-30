# Django ToDo list

This is a todo list web application with basic features of most web apps, i.e., accounts/login, API, and interactive UI. To do this task, you will need:

- CSS | [Skeleton](http://getskeleton.com/)
- JS  | [jQuery](https://jquery.com/)

## Explore

Try it out by installing the requirements (the following commands work only with Python 3.8 and higher, due to Django 4):

```
pip install -r requirements.txt
```

Create a database schema:

```
python manage.py migrate
```

And then start the server (default is http://localhost:8000):

```
python manage.py runserver
```

Now you can browse the [API](http://localhost:8000/api/) or start on the [landing page](http://localhost:8000/).

## Task

1. Fork this repository.
1. Use `kind` to spin up a cluster from a `cluster.yml` configuration file.
1. Create a manifest  named `rbac` inside a `security` directory
1. `rbac` manifest requirements:
    1. File should containa `ServiceAccount` definition
    1. File should contain a `Role` definition
    1. Role should allow to list secrets
    1. File should contain a `RoleBinding` definition
    1. RoleBinding should bind the `Role` to the `ServiceAccount`
1. Use newly created `ServiceAccount` should be used by the `Deployment` in the `deployment` manifest
1. Execute a curl command to list secrets from the `Deployment` pod to list secrets
1. Make a screenshot of the output and attach it to the PR
1. `README.md` should have instructuions on how to validate the changes
1. Create PR with your changes and attach it for validation on a platform.

---

# SOLUTION

1. We inserted the command tht applies `rbac.yml` in our bootstrap sequence
2. we made changes to `ingress.yml` to make it work
3. we executed all as per `bootstrap.sh`

# VALIDATION

1. **we connected to deployment pod**

    ```
    kubectl get pods -n todoapp -o wide
    NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    todoapp-7b95d57f9d-8wms2   1/1     Running   0          82s   10.244.1.3   kind-worker4   <none>           <none>
    todoapp-7b95d57f9d-kxnhn   1/1     Running   0          96s   10.244.3.2   kind-worker3   <none>           <none>
    ---
    kubectl exec -it todoapp-7b95d57f9d-8wms2 -n todoapp -- sh
    # 
    ```
2. **we created environment variables**

    ```
    APISERVER=https://kubernetes.default.svc
    SERVICEAC# COUNT=/var/run/secrets/kubernetes.io/serviceaccount

    TOKEN=$(cat ${SERVICEACCOUNT}/token)
    CACERT=${S# # # ERVICEACCOUNT}/ca.crt
    ```
3. **we requested list of secrets from k8s**
*
    ```
    # curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
    ```

    with the following result

    ```
    {
      "kind": "SecretList",
      "apiVersion": "v1",
      "metadata": {
        "resourceVersion": "2681"
      },
      "items": [
        {
          "metadata": {
            "name": "app-secret",
            "namespace": "todoapp",
            "uid": "0b625089-4292-411e-ae9a-61b8603b3c58",
            "resourceVersion": "1321",
            "creationTimestamp": "2024-06-30T02:09:21Z",
            "annotations": {
              "kubectl.kubernetes.io/last-applied-configuration": "{"apiVersion":"v1","data":{"DB_HOST":"bXlzcWwtMC5teXNxbC5teXNxbC5zdmMuY2x1c3Rlci5sb2NhbAo=","DB_NAME":"YXBwX2RiCg","DB_PASSWORD":"MTIzNA","DB_USER":"YXBwX3VzZXI=","SECRET_KEY":"QGUyKHl4KXYmdGdoM19zPTB5amEtaSFkcGVieHN6XmRnNDd4KS1rJmtxXzN6Zio5ZSoK"},"kind":"Secret","metadata":{"annotations":{},"name":"app-secret","namespace":"todoapp"},"type":"Opaque"}\n"
            },
            "managedFields": [
              {
                "manager": "kubectl-client-side-apply",
                "operation": "Update",
                "apiVersion": "v1",
                "time": "2024-06-30T02:09:21Z",
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
            ]
          },
          "data": {
            "DB_HOST": "bXlzcWwtMC5teXNxbC5teXNxbC5zdmMuY2x1c3Rlci5sb2NhbAo=",
            "DB_NAME": "YXBwX2RiCg",        "DB_PASSWORD": "MTIzNA",
            "DB_USER": "YXBwX3VzZXI=",
            "SECRET_KEY": "QGUyKHl4KXYmdGdoM19zPTB5amEtaSFkcGVieHN6XmRnNDd4KS1rJmtxXzN6Zio5ZSoK"
          },
          "type": "Opaque"
        }
      ]
    ```