# Kubernetes RBAC Task 12

## Розгортання

1. Запусти кластер і застосуй манифести:

chmod +x bootstrap.sh
./bootstrap.sh

2. Перевір, що под створено:
kubectl get pods

3. Зайди всередину пода:
POD=$(kubectl get pod -l app=todoapp -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD -- sh

4. Виконай всередині пода:
curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
     -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
     https://kubernetes.default.svc/api/v1/secrets