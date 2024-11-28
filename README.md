# Django ToDo list

This is a to-do list web application with the basic features of most web apps, i.e., accounts/login, API, and interactive UI. To do this task, you will need:

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

You can now browse the [API](http://localhost:8000/api/) or start on the [landing page](http://localhost:8000/).

## Task

1. Fork this repository.
1. Use `kind` to spin up a cluster from a `cluster.yml` configuration file.
1. Create a manifest  named `rbac` inside a `security` directory
1. `rbac` manifest requirements:
    1. File should contain a `ServiceAccount` definition
    1. File should contain a `Role` definition
    1. Role should allow to list secrets
    1. File should contain a `RoleBinding` definition
    1. RoleBinding should bind the `Role` to the `ServiceAccount`
1. Use newly created `ServiceAccount` should be used by the `Deployment` in the `deployment` manifest
1. Execute a curl command to list secrets from the `Deployment` pod to list secrets
1. Make a screenshot of the output and attach it to the PR
1. Create the `INSTRUCTION.md` with instructions on how to validate the changes
1. Create PR with your changes and attach it for validation on a platform.


# Manual
## Steps to Deploy

1. Spin Up a Kubernetes Cluster with kind
Use kind to create a Kubernetes cluster:
```bash
kind create cluster --config=cluster.yml
```

2. Apply the RBAC Configuration
```bash
kubectl apply -f security/rbac.yml
```

This manifest includes a ServiceAccount, a Role that allows listing secrets, and a RoleBinding that binds the Role to the ServiceAccount.


3. Deploy the Application
```bash
./bootstrap.sh
```

## Validate the Deployment

1. Access the Pod's Shell:`
```bash
kubectl exec -it <pod-name> -n todoapp -- sh
```

2. Set Up the Necessary Variables:
```bash
Inside the shell, define the variables for the API server, token, and CA certificate:
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
```

3. Execute the Curl Command to List Pods
```bash
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/pods
```

## Check the ServiceAccount

To confirm the ServiceAccount is correctly created:
```bash
kubectl get serviceaccount -n todoapp my-service-account-read
```

## Verify the Role
~~~~
```bash
kubectl get role -n todoapp my-secret-role-list
```

## Validate the RoleBinding

```bash
kubectl get rolebinding -n todoapp my-secret-role-list-binding
```

## Check for Errors

```bash
kubectl describe serviceaccount -n todoapp my-service-account-read
kubectl describe role -n todoapp my-secret-role-list
kubectl describe rolebinding -n todoapp my-secret-role-list-binding
```

