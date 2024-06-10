#!/bin/bash

set -e

# Step 1: Create RBAC Manifest
echo "Creating RBAC manifest..."
mkdir -p security
cat <<EOF > security/rbac.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: todoapp-sa
  namespace: todoapp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: todoapp
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets-binding
  namespace: todoapp
subjects:
- kind: ServiceAccount
  name: todoapp-sa
  namespace: todoapp
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
EOF

if kubectl apply -f security/rbac.yml; then
  echo "RBAC manifest applied successfully 😊"
else
  echo "Failed to apply RBAC manifest 😶‍🌫️"
  exit 1
fi

# Step 2: Modify Deployment to Use ServiceAccount
echo "Modifying Deployment to use the new ServiceAccount..."
if kubectl patch deployment todoapp -n todoapp -p '{"spec": {"template": {"spec": {"serviceAccountName": "todoapp-sa"}}}}'; then
  echo "Deployment modified successfully 😊"
else
  echo "Failed to modify Deployment 😶‍🌫️"
  exit 1
fi

# Step 3: Wait for Pods to be Ready
echo "Waiting for pods to be ready..."
if kubectl wait --for=condition=ready pod -l app=todoapp -n todoapp --timeout=120s; then
  echo "Pods are ready 😊"
else
  echo "Pods did not become ready 😶‍🌫️"
  exit 1
fi

# Step 4: Execute curl to List Secrets
echo "Executing curl command to list secrets..."
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath="{.items[0].metadata.name}")
CONTAINER_NAME=$(kubectl get pod $POD_NAME -n todoapp -o jsonpath="{.spec.containers[0].name}")

if kubectl exec $POD_NAME -n todoapp -c $CONTAINER_NAME -- sh -c '
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
'; then
  echo "Secrets listed successfully 😊"
else
  echo "Failed to list secrets 😶‍🌫️"
  exit 1
fi

echo "Validation complete. Please take a screenshot of the above output."
