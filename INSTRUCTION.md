## 🚀 Kubernetes RBAC Verification Guide

Delete previous cluster if exists.

```kind delete cluster --name cluster-name```

Use kind to spin up a cluster from a cluster.yml configuration file.

```kind create cluster --config cluster.yml --name my-cluster```

Run bootstrap script to apply all manifests. (I`m recomending using bash in vs code)
```
    ./bootstrap.sh

    If you get:
    bash: ./bootstrap.sh: Permission denied

    then use:
    bash bootstrap.sh
```
Check created pods.

``` kubectl get pods -n todoapp ```

Example:
```
NAME                       READY   STATUS    RESTARTS   AGE
todoapp-865fc9fd6d-5x58t   0/1     Running   0          2m4s
todoapp-865fc9fd6d-nwzfh   0/1     Running   0          2m4s
```
Take any of them and run this command:
```
kubectl exec -it todoapp-865fc9fd6d-5x58t -n todoapp -- sh
```

Then inside the pod run curl using the ServiceAccount token:
```
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -sSk -H "Authorization: Bearer $TOKEN" \
    https://kubernetes.default.svc/api/v1/secrets
```

### ✅ Done! You’ve successfully verified that your ServiceAccount and RoleBinding allow listing secrets.