## Before validation, create cluster and apply all infrastructure manifests:
```shell
    ./bootstrap.sh
```

## Check that all pods are running:
```shell
    kubectl get pods -n todoapp
```

## Connect to any pod:
```shell
  kubectl exec -it <pod-name> -n todoapp -- /bin/sh
```

## Check if you can read secrets:
```shell
    curl --cacert ${CACERT} \
     --header "Authorization: Bearer ${TOKEN}" \
     -X GET ${APISERVER}/api/v1/namespaces/todoapp/secrets
```
