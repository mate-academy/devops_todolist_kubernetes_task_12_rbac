# Preparation

Before validation, deploy all required Kubernetes resources using the `bootstrap.sh` script.

Make the script executable:

```bash
chmod +x bootstrap.sh
```

Run the script from the root directory of the repository:

```bash
./bootstrap.sh
```

# Validation

## Check if our role is working

Run:

```zsh
kubectl get pods -n todoapp
```

```bash
kubectl exec <your pod name> -it -n todoapp -- sh
```
Than inside the pod run this:

```zsh
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER=https://kubernetes.default.svc
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

You have to see output simular to my in file output.png