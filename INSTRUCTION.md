# How to validate the RBAC changes

The `todoapp` Deployment runs under the `secrets-reader` ServiceAccount. The ServiceAccount, Role (`secrets-lister`) and RoleBinding are defined in [security/rbac.yml](security/rbac.yml). The Role allows only `list` on `secrets` in the `todoapp` namespace.

## Prerequisites

- Docker, [kind](https://kind.sigs.k8s.io/) and `kubectl`

## 1. Create the cluster

```bash
kind create cluster --config cluster.yml
kubectl get nodes
```

## 2. Apply the manifests

The namespace must exist before the RBAC objects, and the ServiceAccount must exist before the Deployment.

```bash
# bootstrap.sh does not apply security/rbac.yml, so apply it manually
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f security/rbac.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml
```

Do not apply `.infrastructure/mysql/` as a directory: files are applied alphabetically, so `configMap.yml` would run before `ns.yml` and fail because the `mysql` namespace does not exist yet.

The first start can take a few minutes (MySQL image pull and initialization). The app pods may restart once or twice until MySQL is ready, this is expected.

Check that everything is created and the pod uses the ServiceAccount:

```bash
kubectl get sa,role,rolebinding -n todoapp
kubectl get pods -n mysql
kubectl wait --for=condition=available deployment/todoapp -n todoapp --timeout=300s
kubectl get deploy todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'
```

Expected output of the last command: `secrets-reader`.

## 3. Check permissions with `kubectl`

```bash
kubectl auth can-i list secrets --as=system:serviceaccount:todoapp:secrets-reader -n todoapp   # yes
kubectl auth can-i delete secrets --as=system:serviceaccount:todoapp:secrets-reader -n todoapp # no
```

## 4. List secrets from inside the pod with curl

```bash
POD=$(kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -n todoapp -- sh
```

Inside the pod:

```bash
SA=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SA/token)
NS=$(cat $SA/namespace)

curl -i --cacert $SA/ca.crt \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/$NS/secrets | head -c 700
```

`curl` is already present in the image (`/usr/bin/curl`). `head -c 700` truncates the output so that secret values are not fully printed.

Expected result: `HTTP/2 200` and a `SecretList` JSON that contains the secrets of the `todoapp` namespace (for example `app-secret`). A screenshot of this output is attached to the PR.

## 5. Negative check (optional)

Other resources must be forbidden, for example pods:

```bash
curl -i --cacert $SA/ca.crt -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/$NS/pods
```

Expected result: `HTTP/2 403` (Forbidden).

## Troubleshooting

- `403` on secrets: check that the namespaces in the Role, RoleBinding and ServiceAccount are all `todoapp`, that `roleRef.name` equals the Role name, and that the RoleBinding subject is the `secrets-reader` ServiceAccount in `todoapp`.
- Pod is not created: the ServiceAccount `secrets-reader` must exist before the Deployment is applied.

## Cleanup

```bash
kind delete cluster
```
