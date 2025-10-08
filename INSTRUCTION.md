# Validation Instructions

Follow these steps to validate the RBAC implementation for listing Kubernetes secrets from the deployment pod.

---

## 1. Prerequisites

- Docker installed
- [kind](https://kind.sigs.k8s.io/) installed
- kubectl installed
- Python 3.8+ (for Django app)

---

## 2. Create and Configure the Cluster

1. Create the Kubernetes cluster using your configuration file:

   ```sh
   kind create cluster --config cluster.yml
   ```

2. Set the current context to the new cluster (if needed):

   ```sh
   kubectl cluster-info
   ```

---

## 3. Apply Manifests

Apply all required manifests in order:

```sh
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/security/rbac.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/deployment.yml
```

---

## 4. Verify ServiceAccount Usage

Check that the deployment uses the correct ServiceAccount:

```sh
kubectl get deployment -n todoapp -o yaml | grep serviceAccountName
```

Expected output:

```
serviceAccountName: secrets-reader
```

---

## 5. List Secrets from the Pod

1. Get the pod name:

   ```sh
   kubectl get pods -n todoapp
   ```

2. Exec into the pod:

   ```sh
   kubectl exec -it <pod-name> -n todoapp -- sh
   ```

3. Inside the pod, run:

   ```sh
   TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
   CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
   curl -s --header "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
   ```

4. You should see a JSON list of secrets.

---

## 6. Attach Screenshot

Take a screenshot of the output from step 5 and attach it to your PR.

---

## 7. Submit PR

- Ensure all changes are committed.
- Open a Pull Request with your changes and the screenshot attached.
