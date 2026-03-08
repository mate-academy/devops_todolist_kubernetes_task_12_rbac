# INSTRUCTION: RBAC Validation

## Step 1: Spin Up the Cluster

```bash
kind create cluster --config cluster.yml
```

Verify the cluster is running:

```bash
kubectl get nodes
```

Expected: all nodes in `Ready` status.

---

## Step 2: Apply All Manifests

```bash
sh bootstrap.sh
```

Verify the resources were created:

```bash
kubectl get sa,role,rolebinding -n <namespace>
```

Expected: ServiceAccount, Role and RoleBinding are present.

---

## Step 3: Validate RBAC with curl

Get the pod name:

```bash
kubectl get pods -n <namespace>
```

Exec into the pod:

```bash
kubectl exec -it <pod-name> -n <namespace> -- sh
```

Run curl inside the pod:

```bash
curl -s \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/<namespace>/secrets
```

link screen: https://ibb.co/svxM3c0J

Expected: response returns a list of secrets with `"kind":"SecretList"`.

If you get `403 Forbidden` — RoleBinding is not configured correctly.

---