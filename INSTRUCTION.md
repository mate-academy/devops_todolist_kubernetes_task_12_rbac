# Інструкція з розгортання та перевірки RBAC

1. Створити кластер Kind:
  ```bash
Створіть кластер Kubernetes за допомогою конфігураційного файлу `cluster.yml`:
kind create cluster --config cluster.yml

Створення просторів імен (Namespaces)
Переконайся, що створено необхідні простори імен (todoapp та mysql):
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/mysql/ns.yml

Застосуйте конфігурацію RBAC (ServiceAccount secrets-reader, Role, RoleBinding):
kubectl apply -f .infrastructure/security/rbac.yml

Перевірка готовності подів та Probes (Health / Readiness)
Перевірка стану подів MySQL:
kubectl get pods -n mysql
# (Чекаємо статус 1/1 Running)
Перевірка стану подів TodoApp:
kubectl get pods -n todoapp
# Чекаємо, поки статус зміниться з 0/1 на 1/1 Running, що свідчить про успішне проходження проб /api/health та /api/ready)
Застосуйте маніфести бази даних MySQL та додатку TodoApp:
kubectl apply -f .infrastructure/mysql/
kubectl apply -f .infrastructure/app/

2. Перевірка доступу до секретів через ServiceAccount (RBAC)

POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n todoapp $POD_NAME -- bash -c '
  APISERVER=https://kubernetes.default.svc
  SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
  TOKEN=$(cat${SERVICEACCOUNT}/token)
  CACERT=${SERVICEACCOUNT}/ca.crt

  curl -s --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
'

Перевірка локальної кінцевої точки додатку
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n todoapp $POD_NAME -- curl -s http://localhost:8080/api/secrets

Усунення несправностей
Огляд подій та детального опису пода:
kubectl describe pod -l app=todoapp -n todoapp

Перегляд логів застосунку:
kubectl logs -l app=todoapp -n todoapp --tail=100

Перезапуск розгортання:
kubectl rollout restart deployment todoapp -n todoapp
