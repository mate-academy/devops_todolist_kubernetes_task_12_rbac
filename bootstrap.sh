#!/bin/bash

echo "Starting deployment..."

echo "Applying RBAC rules..."
kubectl apply -f .infrastructure/security/rbac.yml

kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml

kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/service.yml

kubectl apply -f .infrastructure/ingress/ingress.yml

echo "Deployment finished! Waiting for pods..."
