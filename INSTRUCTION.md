# ✅ Validation Instructions for Task 12: RBAC & Service Account


---

## 🔧 1. Перевірка створених об'єктів

Всі ресурси знаходяться в неймспейсі `todoapp`.

```bash
kubectl get serviceaccount,secrets,role,rolebinding -n todoapp
Очікувані об'єкти:

ServiceAccount: secrets-reader

Role: secrets-reader-role

RoleBinding: secrets-reader-binding

🧪 2. Перевірка доступу до Kubernetes API з поду
bash
Копировать
Редактировать
kubectl exec -it curl-test -n todoapp -- sh
У поді виконайте:

sh
Копировать
Редактировать
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

curl --cacert ${CACERT} \
  --header "Authorization: Bearer ${TOKEN}" \
  -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets