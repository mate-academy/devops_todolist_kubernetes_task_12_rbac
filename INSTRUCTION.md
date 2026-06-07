# 1) How to validate the changes:

**Create cluster:**

    kind create cluster --config cluster.yml

**Create all resource from bootstrap.sh:**

    sh bootstrap.sh

**Apply rbac.yml and deployment.yml:**

    kubectl apply -f rbac.yml
    kubectl apply -f deployment.yml

**Go inside a container:**

    kubectl exec <name_pod> -it -n todoapp -- sh

**Inside container execute next command:**

    curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -X GET https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets