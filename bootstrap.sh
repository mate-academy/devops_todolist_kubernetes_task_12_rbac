#!/usr/bin/env bash
set -euo pipefail

# 1) створити кластер (за потреби)
if ! kind get clusters | grep -q '^todo-cluster$'; then
  kind create cluster --name todo-cluster --config cluster.yml
fi

# 2) застосувати RBAC (оновлений шлях)
kubectl apply -f security/rbac.yml

# 3) застосувати Deployment
kubectl apply -f deployment.yml

echo "[bootstrap] RBAC (security/rbac.yml) і Deployment застосовано."
echo "[bootstrap] Далі дивись INSTRUCTION.md для валідації (curl з пода)."
