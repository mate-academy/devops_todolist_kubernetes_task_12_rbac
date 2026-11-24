# To validate the task

## Spin up the cluster
```bash
kind create cluster --config cluster.yml
```

## Launch the infrastructure
```bash
bash bootstrap.sh
```

## Validate RBAC
Get the list of pods and copy one pod's name:
```bash
kubectl get pods -n todoapp
```

Get inside the pod:
```bash
kubectl exec -it <pod-name> -n todoapp -- sh
```

Inside the pod, run:
```bash
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```