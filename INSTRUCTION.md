# Validation Instructions

## 1. Check the Deployment

Verify that the Deployment exists:

```bash
kubectl get deployment todoapp -n todoapp
```

## 2. Check the ServiceAccount

Verify that the required ServiceAccount exists:

```bash
kubectl get serviceaccount todoapp-service-account -n todoapp
```

## 3. Check the Role

Verify that the Role exists:

```bash
kubectl get role todoapp-role -n todoapp
```

Check the Role permissions:

```bash
kubectl describe role todoapp-role -n todoapp
```

The Role must allow `get` and `list` operations on `secrets`.

## 4. Check the RoleBinding

Verify that the RoleBinding exists:

```bash
kubectl get rolebinding todoapp-role -n todoapp
```

Check that it connects the ServiceAccount with the Role:

```bash
kubectl describe rolebinding todoapp-role -n todoapp
```

## 5. Verify the Deployment ServiceAccount

Check which ServiceAccount is used by the Deployment:

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath="{.spec.template.spec.serviceAccountName}"
```

Expected result:

```text
todoapp-service-account
```

## 6. Check the Pod

List Pods created by the Deployment:

```bash
kubectl get pods -n todoapp
```

The Pod should have status `Running`.

## 7. Verify RBAC permissions

Check whether the ServiceAccount can list Secrets:

```bash
kubectl auth can-i list secrets \
  --as=system:serviceaccount:todoapp:todoapp-service-account \
  -n todoapp
```

Expected result:

```text
yes
```

## 8. List Secrets from the Deployment Pod using curl

Get the Pod name:

```bash
kubectl get pods -n todoapp
```

Enter the Pod:

```bash
kubectl exec -it <POD_NAME> -n todoapp -- sh
```

Inside the Pod, execute:

```bash
curl -k \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
```
