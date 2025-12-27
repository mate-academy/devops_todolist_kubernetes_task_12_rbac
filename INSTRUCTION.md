# RBAC Validation Instructions

1. Spin up the cluster using `kind`:

```
kind create cluster --config cluster.yml
```

Apply manifests:

```
./bootstrap.sh
```

Verify todoapp pods are running:

```
kubectl get pods -n todoapp
```

Access a pod:
```
kubectl exec -it <pod-name> -n todoapp -- sh
```

List secrets from inside the pod:
```
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```