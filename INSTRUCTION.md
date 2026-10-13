# Інструкція з валідації RBAC налаштувань

## 1. Запуск кластера Kind
```bash
kind create cluster --config cluster.yml
```

## 2. Застосування конфігурацій
```bash
kubectl apply -f security/rbac.yaml
kubectl apply -f deployment.yaml
```

## 3. Перевірка доступу до Secrets через Curl
```bash
export POD_NAME=\$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it \$POD_NAME -n todoapp -- curl -sSk \
  -H "Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://default.svc
```
