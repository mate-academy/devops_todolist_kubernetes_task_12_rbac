# ToDo App — RBAC Instructions

## Prerequisites

- `kind` installed (https://kind.sigs.k8s.io/)
- `kubectl` installed and configured
- Docker running locally

## 1. Create the cluster

Spin up a local Kubernetes cluster using `kind` and the provided
configuration file:

```bash
kind create cluster --config cluster.yml
```

Verify the cluster is up:

```bash
kubectl cluster-info --context kind-kind
```

## 2. Deploy all resources

Apply the RBAC manifest first, so the ServiceAccount exists before the
Deployment tries to use it:

```bash
kubectl apply -f security/rbac.yml
kubectl apply -f .infrastructure/app/deployment.yml
```

(Adjust paths above if your other manifests, such as namespace, secrets,
services, etc., need to be applied as well — see previous instructions
for the full bootstrap order.)

## 3. Validate the RBAC resources were created

```bash
kubectl get serviceaccount secrets-reader -n todoapp
kubectl get role secrets-reader -n todoapp
kubectl get rolebinding secrets-reader-binding -n todoapp
```

Confirm the RoleBinding correctly links the Role to the ServiceAccount:

```bash
kubectl describe rolebinding secrets-reader-binding -n todoapp
```

## 4. Validate the Deployment uses the ServiceAccount

```bash
kubectl get pods -n todoapp -o jsonpath='{.items[0].spec.serviceAccountName}'
```

This should print `secrets-reader`.

## 5. List secrets from inside the Deployment pod

Get the name of a running app pod:

```bash
kubectl get pods -n todoapp
```

Open a shell inside the pod:

```bash
kubectl exec -it <pod-name> -n todoapp -- sh
```

(Replace `<pod-name>` with the actual pod name.)

From inside the pod, use `curl` to call the Kubernetes API and list
secrets in the `todoapp` namespace, using the ServiceAccount token that
Kubernetes automatically mounts into the pod:

```sh
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

curl -s --cacert $CACERT \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```

The output should return a JSON list of secrets in the `todoapp`
namespace, confirming that the ServiceAccount's Role permissions
(`list` on `secrets`) are correctly applied.

Take a screenshot of this output for the PR.

Exit the pod shell:

```sh
exit
```

## Cleaning up

```bash
kind delete cluster
```