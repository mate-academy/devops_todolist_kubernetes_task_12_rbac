#!/bin/bash

# Скрипт для развертывания и тестирования RBAC конфигурации
set -e

echo "🚀 Начинаю развертывание TodoList приложения с RBAC..."

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Функция для вывода статуса
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Проверка наличия необходимых утилит
check_prerequisites() {
    echo "🔍 Проверка предварительных требований..."
    
    if ! command -v kind &> /dev/null; then
        print_error "kind не найден. Установите kind: https://kind.sigs.k8s.io/docs/user/quick-start/"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl не найден. Установите kubectl"
        exit 1
    fi
    
    print_status "Все необходимые утилиты найдены"
}

# Создание kind кластера
create_cluster() {
    echo "🏗️  Создание kind кластера..."
    
    # Проверить, существует ли уже кластер
    if kind get clusters | grep -q "todolist-rbac"; then
        print_warning "Кластер todolist-rbac уже существует. Удаляю старый..."
        kind delete cluster --name todolist-rbac
    fi
    
    kind create cluster --config cluster.yml --name todolist-rbac
    print_status "Kind кластер создан успешно"
    
    # Ожидание готовности кластера
    echo "⏳ Ожидание готовности кластера..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    print_status "Кластер готов к работе"
}

# Применение RBAC конфигурации
apply_rbac() {
    echo "🔐 Применение RBAC конфигурации..."
    
    kubectl apply -f security/rbac.yml
    print_status "RBAC ресурсы созданы"
    
    # Проверка созданных ресурсов
    echo "📋 Проверка созданных RBAC ресурсов:"
    kubectl get serviceaccounts todolist-service-account
    kubectl get roles secrets-reader-role  
    kubectl get rolebindings todolist-secrets-reader-binding
}

# Создание тестовых секретов
create_test_secrets() {
    echo "🔑 Создание тестовых секретов..."
    
    kubectl create secret generic test-secret-1 --from-literal=key1=value1 --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret generic test-secret-2 --from-literal=key2=value2 --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password=secret123 --dry-run=client -o yaml | kubectl apply -f -
    
    print_status "Тестовые секреты созданы"
    kubectl get secrets | grep -E "(test-secret|db-credentials)"
}

# Развертывание приложения
deploy_application() {
    echo "🚢 Развертывание приложения..."
    
    kubectl apply -f deployment.yml
    print_status "Deployment применен"
    
    # Ожидание готовности подов
    echo "⏳ Ожидание готовности подов..."
    kubectl wait --for=condition=Ready pods -l app=todolist --timeout=300s
    print_status "Поды готовы к работе"
    
    kubectl get pods -l app=todolist
}

# Тестирование RBAC
test_rbac() {
    echo "🧪 Тестирование RBAC конфигурации..."
    
    # Проверка прав ServiceAccount
    echo "📝 Проверка прав ServiceAccount на чтение секретов:"
    if kubectl auth can-i list secrets --as=system:serviceaccount:default:todolist-service-account; then
        print_status "ServiceAccount может читать секреты"
    else
        print_error "ServiceAccount НЕ может читать секреты"
        exit 1
    fi
    
    echo "📝 Проверка отсутствия избыточных прав (создание секретов):"
    if ! kubectl auth can-i create secrets --as=system:serviceaccount:default:todolist-service-account; then
        print_status "ServiceAccount НЕ может создавать секреты (правильно)"
    else
        print_warning "ServiceAccount может создавать секреты (избыточные права)"
    fi
    
    echo "📝 Проверка отсутствия избыточных прав (удаление секретов):"
    if ! kubectl auth can-i delete secrets --as=system:serviceaccount:default:todolist-service-account; then
        print_status "ServiceAccount НЕ может удалять секреты (правильно)"
    else
        print_warning "ServiceAccount может удалять секреты (избыточные права)"
    fi
}

# Демонстрация доступа к секретам из pod
demonstrate_secrets_access() {
    echo "🔍 Демонстрация доступа к секретам из pod..."
    
    POD_NAME=$(kubectl get pods -l app=todolist -o jsonpath='{.items[0].metadata.name}')
    echo "Используется pod: $POD_NAME"
    
    echo "📡 Выполнение curl запроса для получения списка секретов:"
    
    # Создать временный скрипт для выполнения в pod
    cat > /tmp/test_secrets.sh << 'EOF'
#!/bin/sh
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

echo "Namespace: $NAMESPACE"
echo "Token (first 20 chars): ${TOKEN:0:20}..."
echo ""
echo "Выполнение curl запроса к Kubernetes API..."

curl -s --cacert $CACERT \
     -H "Authorization: Bearer $TOKEN" \
     "https://kubernetes.default.svc.cluster.local/api/v1/namespaces/$NAMESPACE/secrets" \
     | head -50
EOF
    
    # Скопировать скрипт в pod и выполнить
    kubectl cp /tmp/test_secrets.sh $POD_NAME:/tmp/test_secrets.sh -c secrets-reader
    kubectl exec $POD_NAME -c secrets-reader -- chmod +x /tmp/test_secrets.sh
    kubectl exec $POD_NAME -c secrets-reader -- /tmp/test_secrets.sh
    
    # Очистить временный файл
    rm -f /tmp/test_secrets.sh
    
    print_status "Демонстрация завершена"
}

# Показать логи
show_logs() {
    echo "📋 Логи secrets-reader контейнера:"
    POD_NAME=$(kubectl get pods -l app=todolist -o jsonpath='{.items[0].metadata.name}')
    kubectl logs $POD_NAME -c secrets-reader --tail=20
}

# Главная функция
main() {
    echo "🎯 Развертывание TodoList приложения с RBAC в Kubernetes"
    echo "=================================================="
    
    check_prerequisites
    create_cluster
    apply_rbac
    create_test_secrets
    deploy_application
    
    # Небольшая пауза для стабилизации
    sleep 10
    
    test_rbac
    demonstrate_secrets_access
    show_logs
    
    echo ""
    echo "=================================================="
    print_status "🎉 Развертывание завершено успешно!"
    echo ""
    echo "📋 Полезные команды для дальнейшего тестирования:"
    echo "   kubectl get all"
    echo "   kubectl describe pod \$(kubectl get pods -l app=todolist -o jsonpath='{.items[0].metadata.name}')"
    echo "   kubectl logs \$(kubectl get pods -l app=todolist -o jsonpath='{.items[0].metadata.name}') -c secrets-reader"
    echo ""
    echo "🧹 Для очистки ресурсов выполните:"
    echo "   kind delete cluster --name todolist-rbac"
}

# Обработка сигналов для корректного завершения
trap 'echo ""; print_error "Скрипт прерван пользователем"; exit 1' INT TERM

# Запуск главной функции
main "$@"
