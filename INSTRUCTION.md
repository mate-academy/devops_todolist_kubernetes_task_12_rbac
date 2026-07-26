# Instruction

## 1. Starting the cluster

```bash
kind create cluster --config cluster.yml
```

Expected output:
```bash
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.36.1) 🖼 
 ✓ Preparing nodes 📦 📦 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

## 2. Deploying the application

Next, deploy the application using the `bootstrap` script. Before that, don't forget to
grant execute permissions on the script with `+x`.

```bash
./bootstrap
```

## 3. Checking permissions

```bash
kubectl auth can-i list secrets --as=system:serviceaccount:todoapp:secrets-listener -n todoapp
```

Expected output: `yes`

Here we are basically asking whether our service account is allowed to read secrets.

## 4. Practical test

Connect to any of the application pods:

```bash
kubectl exec -it todoapp-5f58d46464-dskwt -n todoapp -- sh
```

Note: your pod name will definitely be different — make sure to check what yours is:

```bash
kubectl get pods -n todoapp
```

And pick any running one.

Run the following:

```bash
APISERVER=https://kubernetes.default.svc
SA=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SA}/token)
CACERT=${SA}/ca.crt
```

Here we save the data into variables so we can pass them to the next command.

Then send a `curl` request, passing the variables we saved:

```bash
curl --cacert ${CACERT} \
  --header "Authorization: Bearer ${TOKEN}" \
  -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```

We expect the API server to return the contents of the Secret object that lives in our
cluster:

```bash
 "data": {
        "DB_HOST": "bXlzcWwtMC5teXNxbC5teXNxbC5zdmMuY2x1c3Rlci5sb2NhbAo=",
        "DB_NAME": "YXBwX2RiCg==",
        "DB_PASSWORD": "MTIzNA==",
        "DB_USER": "YXBwX3VzZXI=",
        "SECRET_KEY": "QGUyKHl4KXYmdGdoM19zPTB5amEtaSFkcGVieHN6XmRnNDd4KS1rJmtxXzN6Zio5ZSoK"
      },
```

The values in `data` are base64-encoded, not encrypted. To decode:
`echo MTIzNA== | base64 -d` → returns `1234`.