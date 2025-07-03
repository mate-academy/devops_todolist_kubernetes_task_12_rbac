# How to validate RBAC and ServiceAccount changes

Follow these steps to validate the RBAC and ServiceAccount configuration for the Django ToDo list application:

## 1. Prepare the cluster

- Ensure you have a running Kubernetes cluster (e.g., using kind and the provided `cluster.yml`).
- Make sure `kubectl` is configured to use the correct context.

## 2. Apply all manifests

Run the provided `bootstrap.sh` script to apply all necessary Kubernetes manifests:

```sh
./bootstrap.sh
```

## 3. Verify the ServiceAccount and RBAC

Check that the `secrets-reader` ServiceAccount, Role, and RoleBinding exist in the `todoapp` namespace:

```sh
kubectl get serviceaccount,secrets,role,rolebinding -n todoapp
```

## 4. Check the deployment

Ensure the `todoapp` deployment is using the `secrets-reader` ServiceAccount:

```sh
kubectl get deployment todoapp -n todoapp -o yaml | grep serviceAccountName
```

The output should include:

```
serviceAccountName: secrets-reader
```

## 5. Get a pod name

Find the name of a running pod from the deployment:

```sh
kubectl get pods -n todoapp
```

## 6. List secrets from inside the pod

Exec into the pod and use `curl` to access the Kubernetes API and list secrets:

```sh
kubectl exec -it <POD_NAME> -n todoapp -- sh
```

Inside the pod, run:

```sh
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/pods
```

You should see a JSON list of secrets in the `todoapp` namespace. This confirms the ServiceAccount and RBAC are working as intended.
