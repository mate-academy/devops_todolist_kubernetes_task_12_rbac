# RBAC validation
Create kind rluster:

```bash
kind create cluster --config cluster.yml
```

Run these commands from the repository root after creating the kind cluster:

```bash
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl wait --for=condition=available deployment/todoapp -n todoapp --timeout=180s
```

Confirm that the deployment uses the RBAC service account and that it can list
secrets in the `todoapp` namespace:

```bash
kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
kubectl auth can-i list secrets \
  --as=system:serviceaccount:todoapp:secrets-reader -n todoapp
```

The second command must print `yes`.

Execute the following curl request from a deployment pod. It authenticates to
the Kubernetes API with the pod's projected service-account token and prints
the secrets visible to that service account:

```bash
POD=$(kubectl get pods -n todoapp -l app=todoapp \
  -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n todoapp "$POD" -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  curl --silent --show-error --insecure \
    -H "Authorization: Bearer $TOKEN" \
    https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
'
```

The response should be a Kubernetes `SecretList` JSON document containing the
secrets in the `todoapp` namespace. Requests for secrets in another namespace
must be denied because the manifest defines a namespace-scoped `Role`.