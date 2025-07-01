#!/bin/bash

set -e

echo "➡️  Створення кластера kind..."
kind create cluster --config .infrastructure/cluster.yml --name todoapp-cluster

echo "⏳ Очікування готовності кластера..."
sleep 10

echo "🏷️ Додавання міток і taint-ів на worker-ноди..."
NODES=$(kubectl get nodes -o name | grep worker)
i=0
for NODE in $NODES; do
  if [ $i -eq 0 ]; then
    echo "  👉 mysql нода: $NODE"
    kubectl label $NODE app=mysql --overwrite
    kubectl taint $NODE app=mysql:NoSchedule --
  else
    echo "  👉 todoapp нода: $NODE"
    kubectl label $NODE app=todoapp --overwrite
  fi
  i=$((i+1))
done

echo "📁 Створення namespace..."
kubectl apply -f .infrastructure/namespace.yml

echo "🔐 Розгортання Secret і ConfigMap..."
kubectl apply -f .infrastructure/secret.yml
kubectl apply -f .infrastructure/configmap.yml

echo "🔐 Розгортання RBAC..."
kubectl apply -f .infrastructure/security/rbac.yml

echo "💾 Розгортання PVC та/або PV (якщо потрібно)..."
kubectl apply -f .infrastructure/pv.yml || true
kubectl apply -f .infrastructure/pvc.yml || true

echo "🐘 Розгортання MySQL StatefulSet..."
kubectl apply -f .infrastructure/mysql/headless-service.yml
kubectl apply -f .infrastructure/mysql/statefulset.yml

echo "📝 Розгортання ToDo App..."
kubectl apply -f .infrastructure/deployment.yml
kubectl apply -f .infrastructure/service.yml

echo "🌐 Розгортання Ingress (якщо є)..."
kubectl apply -f .infrastructure/ingress/ingress.yml || true

echo "✅ Готово. Стан об’єктів у просторі імен todoapp:"
kubectl get all -n todoapp
