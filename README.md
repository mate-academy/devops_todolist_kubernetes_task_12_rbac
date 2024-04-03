# Deployment Guide for Kubernetes Application with Custom RBAC

This README provides detailed instructions on how to deploy a Kubernetes application using a custom RBAC configuration. The application deployment utilizes a ServiceAccount, Role, and RoleBinding to manage access to Kubernetes resources.

## Prerequisites
- kind installed on your machine
- kubectl installed and configured

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
kubectl get serviceaccount -n <namespace> <serviceaccount-name>
```

## Verify the Role
~~~~
```bash
kubectl get role -n <namespace> <role-name>
```

## Validate the RoleBinding

```bash
kubectl get rolebinding -n <namespace> <rolebinding-name>
```

## Check for Errors

```bash
kubectl describe serviceaccount -n <namespace> <serviceaccount-name>
kubectl describe role -n <namespace> <role-name>
kubectl describe rolebinding -n <namespace> <rolebinding-name>
```

Replace <pod-name>, <serviceaccount-name>, <namespace>, <role-name>, <rolebinding-name> with the appropriate values.
