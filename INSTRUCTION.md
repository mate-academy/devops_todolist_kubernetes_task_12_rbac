# Інструкція з розгортання та перевірки RBAC

1. Створення кластера Kind

Створіть кластер Kubernetes за допомогою конфігураційного файлу `cluster.yml`:

kind create cluster --config cluster.yml

2. Створення просторів імен (Namespaces)
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace mysql --dry-run=client -o yaml | kubectl apply -f -

3. Застосування маніфестів
Застосуйте конфігурацію RBAC
kubectl apply -f .infrastructure/security/rbac.yml

Застосуйте маніфести бази даних MySQL:
kubectl apply -f .infrastructure/mysql/

Застосуйте маніфести додатку TodoApp:
kubectl apply -f .infrastructure/app/

Очікування готовності та перевірка Probes (Health / Readiness)
Перевірка стану подів MySQL:
kubectl get pods -n mysql

Очікування стану Ready для додатку TodoApp:
kubectl wait --for=condition=ready pod -l app=todoapp -n todoapp --timeout=120s

Підтвердження відповіді кінцевих точок livenessProbe та readinessProbe (/api/health та /api/ready):
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n todoapp $POD_NAME -- curl -s http://localhost:8080/api/health
kubectl exec -n todoapp $POD_NAME -- curl -s http://localhost:8080/api/ready

Перевірка доступу до секретів через ServiceAccount (RBAC)
Перевірка RBAC прав через Kubernetes API (Основна перевірка)
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
Огляд подій та опису пода:
kubectl describe pod -l app=todoapp -n todoapp

Перегляд логів контейнера:
kubectl logs -l app=todoapp -n todoapp --tail=100

Перезапуск розгортання:
kubectl rollout restart deployment todoapp -n todoapp
