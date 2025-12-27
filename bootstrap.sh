#!/bin/bash
set -e

kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml -n mysql
kubectl apply -f .infrastructure/mysql/secret.yml -n mysql
kubectl apply -f .infrastructure/mysql/service.yml -n mysql
kubectl apply -f .infrastructure/mysql/statefulSet.yml -n mysql --wait

kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml -n todoapp --wait
kubectl apply -f .infrastructure/app/secret.yml -n todoapp
kubectl apply -f .infrastructure/app/configMap.yml -n todoapp
kubectl apply -f .infrastructure/app/clusterIp.yml -n todoapp
kubectl apply -f .infrastructure/app/nodeport.yml -n todoapp
kubectl apply -f .infrastructure/app/hpa.yml -n todoapp

kubectl apply -f .infrastructure/security/rbac.yml -n todoapp
kubectl apply -f .infrastructure/app/deployment.yml -n todoapp --wait

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml -n todoapp
