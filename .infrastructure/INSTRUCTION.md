
Крок 1: Запускаємо поди та перевіряємо:
kubectl get pods -n todoapp

Крок 2: Входимо у контейнер - Замініть <pod_name> на назву вашого пода:
kubectl exec -n todoapp -it <pod_name> -- sh

Крок 3: Виконання запиту до API
Скопіюйте та вставте цю команду одним рядком всередині пода. Вона автоматично підтягне токен та сертифікат безпеки:

SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount && \
TOKEN=$(cat ${SERVICEACCOUNT}/token) && \
CACERT=${SERVICEACCOUNT}/ca.crt && \
APISERVER=https://kubernetes.default.svc && \
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets

