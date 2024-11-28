#!/bin/bash

set -e

# Step 1: Apply RBAC Manifest
echo "Applying RBAC manifest from C:/Users/shche/mate/kubernetes/devops_todolist_kubernetes_task_12_rbac/.infrastructure/Security/rbac.yml..."
if kubectl apply -f C:/Users/shche/mate/kubernetes/devops_todolist_kubernetes_task_12_rbac/.infrastructure/Security/rbac.yml; then
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

echo "Validation complete."
