# INSTRUCTION: Validating RBAC Changes

This guide explains how to validate the RBAC setup that allows the `todoapp` Deployment to list Secrets in its namespace.

## Prerequisites

- A running Kubernetes cluster (e.g. via `kind`)
- `kubectl` configured to point at the cluster

---

## 1. Spin Up the Cluster

```bash
kind create cluster --config cluster.yml
```

---

## 2. Apply All Manifests

Apply resources in the correct order:

```bash
# Namespaces first
kubectl apply -f app/ns.yml
kubectl apply -f mysql/ns.yml

# RBAC (ServiceAccount must exist before Deployment)
kubectl apply -f security/rbac.yml

# ConfigMaps and Secrets
kubectl apply -f app/configMap.yml
kubectl apply -f app/secret.yml
kubectl apply -f mysql/configMap.yml
kubectl apply -f mysql/secret.yml

# Storage
kubectl apply -f app/pv.yml
kubectl apply -f app/pvc.yml

# Workloads
kubectl apply -f app/deployment.yml
kubectl apply -f mysql/statefulSet.yml

# Services & Networking
kubectl apply -f app/clusterIp.yml
kubectl apply -f app/nodeport.yml
kubectl apply -f app/ingress.yml
kubectl apply -f mysql/service.yml

# Autoscaling
kubectl apply -f app/hpa.yml
```

---

## 3. Verify RBAC Resources Were Created

```bash
kubectl get serviceaccount secrets-reader -n todoapp
kubectl get role secrets-reader-role -n todoapp
kubectl get rolebinding secrets-reader-rolebinding -n todoapp
```

Expected output — all three resources should be listed.

---

## 4. Confirm the Deployment Uses the ServiceAccount

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'
```

Expected output:
```
secrets-reader
```

---

## 5. List Secrets from Inside the Pod via curl

Get the name of a running `todoapp` pod:

```bash
kubectl get pods -n todoapp
```

Exec into the pod:

```bash
kubectl exec -it <pod-name> -n todoapp -- /bin/sh
```

Inside the pod, run the following `curl` command to list secrets using the mounted service account token:

```sh
curl -s \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```

### Expected Output

You should receive a JSON response with `"kind": "SecretList"` and a list of secrets in the `todoapp` namespace, for example:

```json
{
  "kind": "SecretList",
  "apiVersion": "v1",
  "items": [
    {
      "metadata": { "name": "app-secret", "namespace": "todoapp" },
      ...
    }
  ]
}
```

If RBAC is **not** configured correctly, you will see a `403 Forbidden` response instead.

---

## 6. Verify HPA is Watching the Deployment

```bash
kubectl get hpa todoapp -n todoapp
```

The `TARGETS` column should show CPU and memory utilization once the metrics server is running.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| `403 Forbidden` from curl | ServiceAccount not bound to Role | Re-apply `security/rbac.yml` |
| Pod stuck in `Pending` | PVC not bound to PV | Check `kubectl get pvc -n todoapp` |
| `ImagePullBackOff` | Image tag unavailable | Verify `ikulyk404/todoapp:4.0.1` is accessible |
| DB connection errors | MySQL pod not ready | Wait for `mysql-0` to become `Running` |