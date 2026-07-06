1 install Python 3.8 and higher, due to Django 4
2 install kind
3 install kubectl

4 kind create cluster --config cluster.yml
5 run ./bootstrap.sh
6 kubectl apply -f .infrastructure/ingress/ingress.yml

7 kubectl apply -f .infrastructure/security/rbac.yml
8 kubectl get pods -n todoapp
9 kubectl exec <pod-name> -it -n mateapp -- sh
10 export APISERVER=https://kubernetes.default.svc
   export TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
   export CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
11 curl --cacert $CACERT \
  -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/todoapp/secrets

Expected results:
mysql pods only on app=mysql nodes, each on separate nodes
todoapp pods preferring app=todoapp nodes and not co-locating