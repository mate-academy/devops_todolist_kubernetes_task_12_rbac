# Інструкція з розгортання та перевірки RBAC

1. Створити кластер Kind:
   ```bash
   kind create cluster --config cluster.yml

Створити namespaces та RBAC:
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/security/rbac.yml

Розгорнути бази даних та застосунок:
kubectl apply -f .infrastructure/mysql/
kubectl apply -f .infrastructure/app/

2. Перевірка доступності секретів через ServiceAccount
Отримати назву пода:
kubectl get pods -n todoapp

Підключитися до пода:
kubectl exec -it <ПОД_ІМ'Я> -n todoapp -- bash

Виконати запит до Kubernetes API для перегляду секретів:
APISERVER=[https://kubernetes.default.svc](https://kubernetes.default.svc)
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
