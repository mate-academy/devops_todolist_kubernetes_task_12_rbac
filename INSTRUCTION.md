## 1. Start the Infrastructure

# For starting all the resources, you should use in Terminal:

```bash
chmod 777 bootstrap.sh
./bootstrap.sh
```

This script will apply all manifests (MySQL, App, RBAC..)

## 2. Check the created resources

# Check the Namespaces

```bash
kubectl get namespaces
```

The namespaces should be created: `mysql`, `todoapp`

# Check the ConfigMaps and Secrets

```bash
kubectl get configmap -n todoapp
kubectl get secret -n todoapp
kubectl get configmap -n mysql
kubectl get secret -n mysql
```

# Verify PV and PVC

```bash
kubectl get pv
kubectl get pvc -n todoapp
```

# Check Service and Ingress

```bash
kubectl get svc -n mysql
kubectl get ingress -n todoapp
```

# Check the Deployment and Pods

```bash
kubectl get deployment -n todoapp
kubectl get pods -n todoapp
kubectl get pods -n mysql
```

## 3. Check the RBAC access

# Verify, if ServiceAccount exists

```bash
kubectl get sa -n todoapp
```

## 4. Test access to Secrets from pod

```bash
kubectl exec -it <pod-name> -n todoapp -- sh
```

And execute:

```bash
curl http://127.0.0.1:8001/api/v1/namespaces/todoapp/secrets
```

Or check mounted secrets:

```bash
ls -l /app/secrets
```
