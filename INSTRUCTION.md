# RBAC Validation Instructions

Ці інструкції показують, як перевірити, що ServiceAccount `todo-sa` має доступ до list secrets у namespace `default`.

---

## 1. Передумови
- Піднятий кластер kind:
```bash
kind create cluster --name todo-cluster --config cluster.yml
Застосовані маніфести:

bash
Копировать
Редактировать
kubectl apply -f security/rbac.yml
kubectl apply -f deployment.yml
2. Перевірити, що Pod працює
bash
Копировать
Редактировать
kubectl get pods -l app=todo-app
Статус має бути Running.

3. Виконати curl з Pod-а
Примітка: На Windows через PowerShell можуть бути проблеми з лапками та змінними. Надійний варіант — передати скрипт у Pod через base64.

Кроки:
Отримати ім'я Pod-а:

bash
Копировать
Редактировать
POD=$(kubectl get pods -l app=todo-app -o jsonpath="{.items[0].metadata.name}")
Виконати скрипт у Pod:

bash
Копировать
Редактировать
SCRIPT=$(cat <<'EOF'
API="https://kubernetes.default.svc"
TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
CACERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
NS="$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)"

apk add --no-cache jq >/dev/null 2>&1 || true

curl --silent --show-error --cacert "$CACERT" \
  -H "Authorization: Bearer $TOKEN" \
  "$API/api/v1/namespaces/$NS/secrets?limit=500" \
  | jq '{kind, count:(.items|length), items:(.items|map(.metadata.name))}'
EOF
)

echo "$SCRIPT" | base64 | kubectl exec -i $POD -- sh -c "base64 -d >/tmp/list.sh && sh /tmp/list.sh"
4. Очікуваний результат
JSON з:

"kind": "SecretList"

"count": <число>"

"items": [...] (список секретів або порожній масив, якщо секретів немає)