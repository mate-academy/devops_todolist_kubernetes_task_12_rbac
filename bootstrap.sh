#!/bin/bash
set -euo pipefail

# Create namespaces + CRITICAL infra (mysql first)
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# App infra and RBAC: ensure RBAC applied before deployment to give pods correct permissions
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml

# Apply RBAC before the deployment so ServiceAccount permissions exist prior to pod creation
kubectl apply -f .infrastructure/security/rbac.yml

# Apply Deployment after RBAC
kubectl apply -f .infrastructure/app/deployment.yml

# Wait for the deployment to roll out (timeout avoids indefinite hangs)
kubectl -n todoapp rollout status deployment/todoapp --timeout=120s

# Install Ingress Controller (idempotent)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml
