
## How to Deploy the App

Use this command to create a Kubernetes cluster:
```bash
kind create cluster --config=cluster.yml
```

Apply the RBAC Configuration
```bash
kubectl apply -f security/rbac.yml
```

Deploy the App
```bash
./bootstrap.sh
```

## How to validate the Deployment

Access the Pod's Shell:`
```bash
kubectl exec -it <pod_name> -n todoapp -- sh
```

Set Up Variables:
```bash
Inside the shell, define the variables for the API server, token, and CA certificate:
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
```

Execute the Curl Command to List Pods
```bash
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/pods
```

And then start the server (default is http://localhost:8000):
## Check the ServiceAccount

To confirm the ServiceAccount is correctly created:
```bash
kubectl get serviceaccount -n <namespace> <serviceaccount_name>
```

## Verify the Role
~~~~
```bash
kubectl get role -n <namespace> <role_name>
```
python manage.py runserver
## Validate the RoleBinding
```bash
kubectl get rolebinding -n <namespace> <rolebinding_name>
```
Now you can browse the [API](http://localhost:8000/api/) or start on the [landing page](http://localhost:8000/).
## Check for Errors
## Task
```bash
kubectl describe serviceaccount -n <namespace> <serviceaccount_name>
kubectl describe role -n <namespace> <role_name>
kubectl describe rolebinding -n <namespace> <rolebinding_name>
```
