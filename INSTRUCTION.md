Застосуйте RBAC маніфест з директорії kubectl apply -f .infrastructure/security/rbac.yml
Маніфест повинен містити:

ServiceAccount

Role з правами list для secrets

RoleBinding, який прив’язує Role до ServiceAccount

Перевірка використання ServiceAccount
Переконайтесь, що Deployment використовує створений ServiceAccount:

kubectl get deployment -n todoapp -o yaml | grep serviceAccountName
Перевірка запуску Pod
kubectl get pods -n todoapp
Pod повинен бути у стані Running.

Виконання curl з Pod для отримання secrets
Увійдіть у Pod Deployment:

kubectl exec -it <pod-name> -n todoapp -- sh
Всередині Pod виконайте:

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

curl --cacert $CACERT \
  -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets
Очікуваний результат
Команда curl повинна повернути JSON зі списком secrets.