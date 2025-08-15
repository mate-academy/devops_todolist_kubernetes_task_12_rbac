Створити кластер Kind за допомогою конфігураційного файлу cluster.yml командою:

bash bootstrap.sh
	2.	Перевірити, що кластер запущений та ноди доступні:
    3.	Створити RBAC ресурси
Створіть ServiceAccount, Role та RoleBinding:
kubectl apply -f .infrastructure/security/rbac
	4.	Перевірити, що ServiceAccount створений
kubectl get serviceaccounts -n todoapp
8.	Перевірити стан подів
kubectl get pods -n todoapp
kubectl describe pod <pod_name> -n todoapp
	9.	Підключитися до пода і перевірити доступ до секретів
Виконайте команду, щоб відкрити shell у контейнері:
kubectl exec -it <pod_name> -n todoapp – /bin/sh
Виконайте команду всередині пода:
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
curl -sSk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/secrets