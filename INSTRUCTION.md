# 🔐 Validation Instructions: RBAC and Secret Access

This document provides steps to validate the RBAC implementation and verify that the `todoapp` deployment can successfully list secrets using its dedicated `ServiceAccount`.

## 🏗️ 1. Environment Setup

1. **Spin up the cluster**:
Ensure you are using the provided `cluster.yml` configuration:
```bash
kind create cluster --config cluster.yml --name todoapp-cluster

```


2. **Run the bootstrap script**:
This script applies all infrastructure manifests, including the new RBAC rules:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```



## 🔍 2. Verifying RBAC Resources

Check if the RBAC components were created correctly in the `todoapp` namespace:

```bash
# Check ServiceAccount
kubectl get sa todoapp-sa -n todoapp

# Check Role and permissions
kubectl get role secrets-reader -n todoapp -o yaml

# Check RoleBinding
kubectl get rolebinding todoapp-secret-binding -n todoapp

```

---

## 🧪 3. Validating Secret Access (The `curl` Test)

To confirm that the `Deployment` is using the `ServiceAccount` and has the necessary permissions, follow these steps:

### Step 1: Get the Pod name

```bash
export POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
```

### Step 2: Verify the assigned ServiceAccount

Check if the pod is actually using `todoapp-sa`:

```bash
kubectl get pod $POD_NAME -n todoapp -o jsonpath='{.spec.serviceAccountName}'
# Expected output: todoapp-sa
```

### Step 3: Execute the `curl` command inside the Pod

We will use the internal Kubernetes API token to list secrets. Run this command:

```bash
kubectl exec -it $POD_NAME -n todoapp -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token);
  CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt;
  curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets'

```

### ✅ Expected Result

The output should be a **JSON object** with `kind: "SecretList"`. It should list at least the `app-secret` used by the application.

*If you see a `403 Forbidden` error, the RoleBinding or Role is misconfigured.*

---

## 📸 4. PR Requirements

As per the task requirements, please ensure you have:

1. Created the `rbac.yml` in the `security/` directory.
2. Updated the `deployment.yml` to include `serviceAccountName: todoapp-sa`.
3. Attached a **screenshot** of the JSON output from the `curl` command above to your Pull Request.

---

## 🧹 5. Cleanup

To delete the cluster:

```bash
kind delete cluster --name todoapp-cluster
```
