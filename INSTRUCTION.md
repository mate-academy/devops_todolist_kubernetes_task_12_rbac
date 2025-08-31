# Инструкция по валидации RBAC настроек в Kubernetes

## Обзор

Этот проект демонстрирует настройку RBAC (Role-Based Access Control) в Kubernetes для Django TodoList приложения. ServiceAccount получает права на чтение секретов в namespace.

## Предварительные требования

- Docker Desktop с включенным Kubernetes ИЛИ
- kind (Kubernetes in Docker) - рекомендуется
- kubectl CLI
- curl (для тестирования API)

## Пошаговая инструкция по развертыванию

### 1. Создание kind кластера

```bash
# Создать кластер с использованием конфигурации
kind create cluster --config cluster.yml --name todolist-rbac

# Проверить статус кластера
kubectl cluster-info --context kind-todolist-rbac
```

### 2. Применение RBAC манифестов

```bash
# Применить RBAC конфигурацию
kubectl apply -f security/rbac.yml

# Проверить созданные ресурсы
kubectl get serviceaccounts
kubectl get roles
kubectl get rolebindings
```

### 3. Развертывание приложения

```bash
# Применить deployment с использованием ServiceAccount
kubectl apply -f deployment.yml

# Проверить статус deployment
kubectl get deployments
kubectl get pods
```

### 4. Создание тестовых секретов

```bash
# Создать несколько тестовых секретов для демонстрации
kubectl create secret generic test-secret-1 --from-literal=key1=value1
kubectl create secret generic test-secret-2 --from-literal=key2=value2
kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password=secret123

# Проверить созданные секреты
kubectl get secrets
```

## Валидация RBAC настроек

### 1. Проверка доступа к секретам из pod

```bash
# Получить имя pod с приложением
POD_NAME=$(kubectl get pods -l app=todolist -o jsonpath='{.items[0].metadata.name}')

# Войти в контейнер secrets-reader и выполнить curl команду
kubectl exec -it $POD_NAME -c secrets-reader -- /bin/sh

# Внутри контейнера выполнить:
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

# Получить список секретов через Kubernetes API
curl -s --cacert $CACERT \
     -H "Authorization: Bearer $TOKEN" \
     "https://kubernetes.default.svc.cluster.local/api/v1/namespaces/$NAMESPACE/secrets"
```

### 2. Альтернативный способ - использование kubectl

```bash
# Проверить доступ ServiceAccount к секретам
kubectl auth can-i list secrets --as=system:serviceaccount:default:todolist-service-account

# Должно вернуть "yes"
```

### 3. Проверка логов контейнера

```bash
# Посмотреть логи secrets-reader контейнера
kubectl logs $POD_NAME -c secrets-reader

# Вы должны увидеть JSON ответ со списком секретов
```

### 4. Проверка отсутствия избыточных прав

```bash
# Проверить, что ServiceAccount НЕ может создавать секреты
kubectl auth can-i create secrets --as=system:serviceaccount:default:todolist-service-account

# Должно вернуть "no"

# Проверить, что ServiceAccount НЕ может удалять секреты
kubectl auth can-i delete secrets --as=system:serviceaccount:default:todolist-service-account

# Должно вернуть "no"
```

## Ожидаемые результаты

1. **ServiceAccount создан**: `todolist-service-account` должен быть виден в выводе `kubectl get sa`

2. **Role настроен**: `secrets-reader-role` должен иметь права только на `get`, `list`, `watch` для ресурса `secrets`

3. **RoleBinding работает**: Связывает ServiceAccount с Role

4. **Pod использует ServiceAccount**: В deployment указан `serviceAccountName: todolist-service-account`

5. **Доступ к API работает**: curl команда из pod должна возвращать список секретов в JSON формате

6. **Принцип минимальных привилегий**: ServiceAccount имеет только необходимые права на чтение секретов

## Примеры вывода

### Успешный curl запрос:

```json
{
  "kind": "SecretList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "1234"
  },
  "items": [
    {
      "metadata": {
        "name": "test-secret-1",
        "namespace": "default"
      },
      "type": "Opaque"
    }
  ]
}
```

### Проверка прав:

```bash
$ kubectl auth can-i list secrets --as=system:serviceaccount:default:todolist-service-account
yes

$ kubectl auth can-i create secrets --as=system:serviceaccount:default:todolist-service-account
no
```

## Очистка ресурсов

```bash
# Удалить все созданные ресурсы
kubectl delete -f deployment.yml
kubectl delete -f security/rbac.yml
kubectl delete secrets test-secret-1 test-secret-2 db-credentials

# Удалить kind кластер
kind delete cluster --name todolist-rbac
```

## Устранение неполадок

### Pod не запускается

- Проверить логи: `kubectl logs <pod-name> -c <container-name>`
- Проверить события: `kubectl describe pod <pod-name>`

### Нет доступа к секретам

- Убедиться, что ServiceAccount привязан к pod
- Проверить RoleBinding: `kubectl describe rolebinding todolist-secrets-reader-binding`
- Проверить права Role: `kubectl describe role secrets-reader-role`

### curl команда не работает

- Проверить, что API server доступен из pod
- Убедиться, что токен ServiceAccount присутствует в pod
- Проверить сертификаты CA

## Безопасность

- ServiceAccount имеет минимально необходимые права (только чтение секретов)
- Контейнеры работают от непривилегированного пользователя
- Использован readOnlyRootFilesystem где возможно
- Отключен allowPrivilegeEscalation

Эта конфигурация демонстрирует best practices для RBAC в Kubernetes с применением принципа минимальных привилегий.
