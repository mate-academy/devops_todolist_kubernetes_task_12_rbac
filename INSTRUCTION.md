1. Apply resources:


    kind create cluster --name todo-cluster --config cluster.yml
    kubectl create namespace todoapp
    kubectl create namespace mysql
    chmod +x bootstrap.sh
    kubectl apply -f ./bootstrap.sh

2. Apply rbac:


    kubectl apply -f security/rbac.yml

3. Check permissions to secrets from the pod:


    kubectl exec -it -n todoapp $(kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{.items[0].metadata.name}') -- /bin/sh
Run curl to list secrets:

    TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 
    curl -sSk -H "Authorization: Bearer $TOKEN" \ https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets

Expect to see yaml with kind "SecretList" and "data" field with corresponding keys.