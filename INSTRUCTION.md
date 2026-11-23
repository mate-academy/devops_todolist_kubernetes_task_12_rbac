# Task 12 — Kubernetes RBAC: Validation Instructions

## Prerequisites

Install Docker Desktop, `kind`, and `kubectl`. Run all commands from the repository root. The example uses a kind cluster named `practice` and the Django application in the `todoapp` namespace. Docker Desktop must be running.

**Security note:** Listing Kubernetes Secrets is a privileged operation used here for training. The dedicated ServiceAccount is granted only the `list` permission within the `todoapp` namespace. Do not expose ServiceAccount tokens, Secret `data`, passwords, or other credentials in screenshots or Pull Requests.

## 1. Create or select the Kubernetes cluster

If the cluster does not exist, create it using the repository configuration:

```bash
kind get clusters
kind create cluster --name practice --config cluster.yml
```

Skip `kind create cluster` if `practice` already exists. Select the correct context and check the nodes:

```bash
kubectl config use-context kind-practice
kubectl get nodes
```

All nodes should become `Ready`. If a different cluster name is used, select its corresponding `kind-<cluster-name>` context instead.

## 2. Deploy the application and RBAC resources

The `bootstrap.sh` script deploys MySQL, creates the `todoapp` namespace, applies `security/rbac.yml` **before** deploying Django, and then waits for the workloads to become ready.

```bash
bash bootstrap.sh
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
```

The Django Pod should become `1/1 Running`. MySQL needs to be ready for the application's readiness checks to succeed.

## 3. Verify ServiceAccount, Role, and RoleBinding

The `security/rbac.yml` manifest defines these resources in the `todoapp` namespace:

- `ServiceAccount` named `secrets-lister`.
- `Role` named `secrets-lister`, allowing the `list` verb on the core API resource `secrets`.
- `RoleBinding` named `secrets-lister-binding`, assigning that Role to the ServiceAccount.

Inspect the resources:

```bash
kubectl get serviceaccount secrets-lister -n todoapp
kubectl get role secrets-lister -n todoapp
kubectl get rolebinding secrets-lister-binding -n todoapp
kubectl describe role secrets-lister -n todoapp
kubectl describe rolebinding secrets-lister-binding -n todoapp
```

Check the effective permissions:

```bash
kubectl auth can-i list secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-lister
kubectl auth can-i delete secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-lister
```

Expected results are `yes` for `list` and `no` for `delete`, provided no other bindings grant additional permissions.

## 4. Verify that the Deployment uses the ServiceAccount

The Django Deployment must specify `serviceAccountName: secrets-lister` in `spec.template.spec`.

```bash
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
kubectl get pods -n todoapp -o custom-columns=NAME:.metadata.name,SERVICEACCOUNT:.spec.serviceAccountName
```

Both checks should identify `secrets-lister`.

## 5. List Secrets from inside a Django Pod with curl

Run this command **from your local terminal**. The request itself runs inside the Django Pod, using its mounted ServiceAccount token and Kubernetes CA certificate. The output includes the HTTP status and Secret names only, not their values.

```bash
kubectl exec -n todoapp deployment/todoapp -- sh -c '
SA=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat "$SA/token")
curl -sS --cacert "$SA/ca.crt" -H "Authorization: Bearer $TOKEN" -o /tmp/rbac-secrets-response.json -w "HTTP status: %{http_code}\n" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
python -c "import json; print(\"Secret names:\", [item[\"metadata\"][\"name\"] for item in json.load(open(\"/tmp/rbac-secrets-response.json\")).get(\"items\", [])])"
rm -f /tmp/rbac-secrets-response.json
'
```

Expected output resembles:

```text
HTTP status: 200
Secret names: ['app-secret']
```

Names depend on the resources created in the namespace. `HTTP status: 200` confirms a successful request. The command assumes the Django image includes `curl` and Python.

**Pull Request screenshot:** Capture the terminal with the in-Pod `curl` command and its successful response. The screenshot must not expose the token, Secret values, decoded credentials, or response `data` fields. Attach the screenshot to the PR.

## 6. Troubleshooting

If the API responds with `403 Forbidden`, confirm that the three RBAC resources use namespace `todoapp`, the Role contains `resources: ["secrets"]` and `verbs: ["list"]`, and the RoleBinding refers to `secrets-lister`:

```bash
kubectl describe role secrets-lister -n todoapp
kubectl describe rolebinding secrets-lister-binding -n todoapp
kubectl auth can-i list secrets -n todoapp --as=system:serviceaccount:todoapp:secrets-lister
```

If the Pod cannot start or is not ready, inspect its events, ServiceAccount, and logs:

```bash
kubectl get pods -n todoapp
kubectl describe deployment todoapp -n todoapp
kubectl get serviceaccounts -n todoapp
kubectl logs -n todoapp deployment/todoapp --tail=50
```

If `kubectl` reports `localhost:8080 connection refused`, check that the kind cluster exists and switch to the correct context:

```bash
kind get clusters
kubectl config use-context kind-practice
kubectl get nodes
```

## 7. Submission

Ensure the Pull Request includes `security/rbac.yml`, the updated Django Deployment manifest, the updated `bootstrap.sh`, this `INSTRUCTION.md`, and the screenshot of the successful in-Pod API request. Do not commit `.idea/`, local credentials, or cluster state.

```bash
git status
git add security/rbac.yml .infrastructure/app/deployment.yml bootstrap.sh INSTRUCTION.md
git diff --cached --stat
git commit -m "Configure namespace-scoped RBAC for Django ServiceAccount"
git push -u origin develop
```

If the changes have already been committed, make a new commit only for subsequent corrections. Open or update the PR from `develop` to the repository's intended base branch and attach the screenshot before submitting the PR URL on the Mate Academy platform.
