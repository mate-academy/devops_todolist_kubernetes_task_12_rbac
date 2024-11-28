# Django ToDo list

This is a to-do list web application with the basic features of most web apps, i.e., accounts/login, API, and interactive UI. To do this task, you will need:

- CSS | [Skeleton](http://getskeleton.com/)
- JS  | [jQuery](https://jquery.com/)

## Explore

Try it out by installing the requirements (the following commands work only with Python 3.8 and higher, due to Django 4):

```
pip install -r requirements.txt
```

Create a database schema:

```
python manage.py migrate
```

And then start the server (default is http://localhost:8000):

```
python manage.py runserver
```

You can now browse the [API](http://localhost:8000/api/) or start on the [landing page](http://localhost:8000/).

## Task

1. Fork this repository.
1. Use `kind` to spin up a cluster from a `cluster.yml` configuration file.
1. Create a manifest  named `rbac` inside a `security` directory
1. `rbac` manifest requirements:
    1. File should contain a `ServiceAccount` definition
    1. File should contain a `Role` definition
    1. Role should allow to list secrets
    1. File should contain a `RoleBinding` definition
    1. RoleBinding should bind the `Role` to the `ServiceAccount`
1. Use newly created `ServiceAccount` should be used by the `Deployment` in the `deployment` manifest
1. Execute a curl command to list secrets from the `Deployment` pod to list secrets
1. Make a screenshot of the output and attach it to the PR
1. Create the `INSTRUCTION.md` with instructions on how to validate the changes
1. Create PR with your changes and attach it for validation on a platform.


---

### Validation

Verify the `Role` is created:

```bash
kubectl get roles -n todoapp
```
Expected output:
```yaml
NAME             CREATED AT
secrets-reader   2024-07-11T10:33:47Z
```
Describe the `Role` to ensure it allows listing secrets:

```bash
kubectl describe role secrets-reader -n todoapp
```
Expected output:
```yaml
Name:         secrets-reader
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  secrets    []                 []              [list]
```

Verify the `RoleBinding` is created :

```bash
kubectl get rolebinding -n todoapp
```
Expected output:
```yaml
NAME                     ROLE                  AGE
secrets-reader-binding   Role/secrets-reader   19m
```
Describe the `RoleBinding` to ensure it properly binds the `Role` to the `ServiceAccount`:
```bash
kubectl describe rolebinding secrets-reader-binding -n todoapp
```
Expected output:
```yaml
Name:         secrets-reader-binding
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  secrets-reader
Subjects:
  Kind            Name            Namespace
  ----            ----            ---------
  ServiceAccount  secrets-reader
```
Check the `ServiceAccount` is used by the `Deployment`:
```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}'
```
Expected output:
```yaml
secrets-reader
```
