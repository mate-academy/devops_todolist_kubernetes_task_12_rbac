## 1. Create the cluster

```
kind create cluster --config cluster.yml
```

## 2. Apply all manifests

```
bash bootstrap.sh
```

## 3. Check that the pods exist

```
kubectl get pods -n todoapp
```

Right after the start there will be 2 pods (the `minReplicas` of the HPA). Under load there can be up to 5 pods (`maxReplicas`). Every pod should have `READY` = `1/1` and `STATUS` = `Running`.

## 4. Check the pods' names and their ServiceAccount

```
kubectl get pods -n todoapp \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.serviceAccountName}{"\n"}{end}'
```

In the second column you should see `todoapp-sa` for every pod.

## 5. Get inside a pod

```
kubectl exec -it <pod-name> -n todoapp -- sh
```

## 6. List the secrets (allowed)

Run inside the pod:

```
curl https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

You should see `"kind": "SecretList"` and the `app-secret` item with its values in base64.

## 7. Get one secret by name (forbidden)

Run inside the pod:

```
curl https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets/app-secret \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

You should see `"reason": "Forbidden"` and `"code": 403`, because the Role allows only the `list` verb.
