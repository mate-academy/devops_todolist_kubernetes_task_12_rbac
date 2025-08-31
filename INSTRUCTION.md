 Validation Instructions for Kubernetes Deployment

## 1. Create the Kubernetes Cluster

Use the provided kind config `cluster.yml` to create the cluster before applying any manifests:

kind create cluster --config cluster.yml


Optionally, you can delete the cluster after testing with:

kind delete cluster


## 2. Start the Infrastructure

Make the bootstrap script executable and run it to deploy all resources (MySQL, App, RBAC):

chmod 777 ./bootstrap.sh
./bootstrap.sh


## 3. Check the Created Resources

### Namespaces:

kubectl get namespaces


Verify namespaces `mysql` and `todoapp` are created.

### ConfigMaps and Secrets:

kubectl get configmap -n todoapp
kubectl get secret -n todoapp
kubectl get configmap -n mysql
kubectl get secret -n mysql


### Persistent Volumes and Claims:

kubectl get pv
kubectl get pvc -n todoapp


### Services and Ingress:

kubectl get svc -n mysql
kubectl get ingress -n todoapp


### Deployments and Pods:

kubectl get deployment -n todoapp
kubectl get pods -n todoapp
kubectl get pods -n mysql

---

## 4. Check the RBAC Access

Verify the ServiceAccount exists:

kubectl get sa -n todoapp


---

## 5. Test Access to Secrets from Pod

1. Get the Pod name of your todoapp:

kubectl get pods -n todoapp



2. Exec into the pod (replace `<pod-name>`):

kubectl exec -it <pod-name> -n todoapp -- sh


3. Inside the pod, run:

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/todoapp/secrets



**Note:**  
- Confirm your container image `ikulyk404/todoapp:4.0.1` includes `curl`.  
- If `curl` is missing, use a sidecar container with image `curlimages/curl:latest` or run an ephemeral pod with curl for testing:

kubectl run -n todoapp curl --image=curlimages/curl:latest -it --rm -- sh



and then run the `curl` command inside this pod with the mounted ServiceAccount.

---