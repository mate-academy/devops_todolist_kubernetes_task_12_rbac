
    kind create cluster --config cluster.yml


    kubectl cluster-info


---

apply all manifests


kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/security/rbac.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/deployment.yml


---


kubectl get deployment -n todoapp -o yaml | grep serviceAccountName



    kubectl get pods -n todoapp


    kubectl exec -it <pod-name> -n todoapp -- sh





    TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    curl -s --header "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets

