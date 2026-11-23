#!/bin/bash
set -e

# Deploy MySQL
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# Wait for MySQL
kubectl rollout status statefulset/mysql -n mysql --timeout=300s

# Create application namespace
kubectl apply -f .infrastructure/app/ns.yml

# Configure RBAC before deploying Django
kubectl apply -f security/rbac.yml

# Deploy Django dependencies
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml

# Deploy Django
kubectl apply -f .infrastructure/app/deployment.yml

# Wait for Django
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s

# Verify resources
kubectl get serviceaccounts -n todoapp
kubectl get roles,rolebindings -n todoapp
kubectl get pods -n todoapp -o wide

echo "Deployment completed."
