# Запуск кластеру Kind
# Переконайтесь, що у вас встановлений kind (https://kind.sigs.k8s.io/).
# Запустіть кластер за допомогою файлу конфігурації cluster.yml:
kind create cluster --config cluster.yml

# Застосування RBAC манифесту
# Перейдіть у папку security.
# Застосуйте RBAC манифест (файл rbac.yml):
kubectl apply -f .infrastructure/security/rbac.yml

# Оновлення Deployment
# Переконайтесь, що Deployment у вашому манифесті використовує створений ServiceAccount.
# Застосуйте манифест Deployment:
kubectl apply -f .infrastructure/app/deployment.yml

#  Перевірка доступу до секретів із поду
# Отримайте ім'я поду, який запущений вашим Deployment:
kubectl get pods

# Виконайте команду curl всередині поду для отримання списку секретів:
kubectl exec -n todoapp -it <pod-name> -- sh -c 'curl -s --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets --insecure'
