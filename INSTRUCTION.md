```bash
kind create cluster --name todo-lab --config cluster.yml
kubectl config use-context kind-todo-lab
kubectl get nodes
```
Check RBAC resources

```bash
kubectl get serviceaccount -n todoapp
kubectl get role -n todoapp
kubectl get rolebinding -n todoapp
```
Verify Deployment

```bash
kubectl rollout status deployment/todoapp -n todoapp
kubectl get pods -n todoapp -o wide
```
```bash
kubectl exec -it -n todoapp deployment/todoapp -- sh
```
If the Pod is not Running, inspect:

```bash
kubectl describe deployment todoapp -n todoapp
kubectl get pods -n todoapp
```
