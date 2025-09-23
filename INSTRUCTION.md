# Instructions to Validate the RBAC Task

This guide explains how to validate the RBAC configuration and confirm that the `todoapp` Deployment can use the ServiceAccount to list Kubernetes secrets.

---

## 1. Create the Kind Cluster

Spin up a new kind cluster from the configuration file:

```bash
kind create cluster --config .infrastructure/cluster.yml
```

## 2. Deploy Namespaces and RBAC

Apply the required namespaces and RBAC configuration:

```bash
kubectl apply -f .infrastructure/namespaces/
kubectl apply -f .infrastructure/security/rbac.yml
```

This will create:

* A ServiceAccount (`todoapp-sa`) in the `todoapp` namespace
* A Role that allows list access on secrets
* A RoleBinding to connect the ServiceAccount with the Role

## 3. Deploy the Application

Apply the ConfigMap, Secret, PersistentVolume, and Deployment:

```bash
kubectl apply -f .infrastructure/configmap.yml
kubectl apply -f .infrastructure/secret.yml
kubectl apply -f .infrastructure/pv.yml
kubectl apply -f .infrastructure/pvc.yml
kubectl apply -f .infrastructure/deployment.yml
```

## 4. Verify the ServiceAccount

Check that the `todoapp` pod is using the `todoapp-sa` ServiceAccount:

```bash
kubectl get pod -n todoapp -o jsonpath="{.items[0].spec.serviceAccountName}"
```

**Expected output:**

```bash
todoapp-sa
```

## 5. Execute a Curl Command Inside the Pod

Find the running `todoapp` pod:

```bash
kubectl get pods -n todoapp
```

Open an interactive shell:

```bash
kubectl exec -it <todoapp-pod-name> -n todoapp -- sh
```

Inside the pod, run:

```bash
curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets | jq .
```

This should output the list of secrets in the `todoapp` namespace.

## 6. Validation

* The ServiceAccount must be correctly bound to the Role.
* The pod must successfully list secrets using the Kubernetes API.
* Take a screenshot of the secrets list output and attach it to your PR.
