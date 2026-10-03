# Kubernetes RBAC: покрокове виконання і перевірка

Цей файл пояснює, що саме потрібно змінити для завдання, чому це працює,
як перевірити доступ із Deployment Pod, де розмістити скріншот і як відправити
зміни в GitHub. Маніфести потрібно додати самостійно.

## 1. ELI5: що будуємо

- `ServiceAccount` — Kubernetes-акаунт, від імені якого працює Pod.
- `Role` — список дозволених дій у конкретному Namespace.
- `RoleBinding` — зв'язок між ServiceAccount і Role.
- `serviceAccountName` у Deployment — вказує, який ServiceAccount отримають Pods.

Ланцюжок доступу:

```text
Deployment Pod
  -> ServiceAccount secrets-reader
  -> RoleBinding secrets-reader
  -> Role secrets-reader
  -> дозвіл list для secrets у Namespace todoapp
```

Role є namespaced-ресурсом. Тому ServiceAccount, Role, RoleBinding, Deployment і
Secrets повинні використовувати Namespace `todoapp`.

## 2. Заповнити security/rbac.yml

Файл `security/rbac.yml` уже існує, але зараз порожній. Додай у нього три
документи, розділені `---`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: secrets-reader
  namespace: todoapp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secrets-reader
  namespace: todoapp
rules:
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secrets-reader
  namespace: todoapp
subjects:
  - kind: ServiceAccount
    name: secrets-reader
    namespace: todoapp
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secrets-reader
```

Пояснення:

- `apiGroups: [""]` означає core API group, у якій знаходиться ресурс Secret.
- `resources: ["secrets"]` обмежує дозвіл тільки Secrets.
- `verbs: ["list"]` дозволяє лише отримати список Secrets.
- `get`, `create`, `update`, `patch`, `delete` не додавай: завдання їх не вимагає.
- `roleRef.name` повинен точно збігатися з `Role.metadata.name`.
- `subjects[0].name` повинен точно збігатися з `ServiceAccount.metadata.name`.

HTTP `GET` до колекції `/api/v1/namespaces/todoapp/secrets` перевіряється
Kubernetes як RBAC-дія `list`. `get` потрібний для запиту одного конкретного
Secret, але не для списку.

## 3. Перевірити Deployment

У `.infrastructure/app/deployment.yml` всередині `spec.template.spec` має бути:

```yaml
    spec:
      serviceAccountName: secrets-reader
      containers:
```

У поточному файлі цей рядок уже є, тому повторно додавати його не потрібно.
Важливо, щоб `serviceAccountName` був на одному рівні з `containers`, а не
всередині контейнера.

Після зміни Pod використовуватиме токен ServiceAccount `secrets-reader`, а не
Namespace ServiceAccount `default`.

## 4. Додати RBAC у bootstrap.sh

Namespace потрібно створити раніше за namespaced RBAC-ресурси. У
`bootstrap.sh` знайди:

```bash 
kubectl apply -f .infrastructure/app/ns.yml
```

Одразу після нього додай:

```bash
kubectl apply -f security/rbac.yml
```

Потрібний порядок:

```bash
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f security/rbac.yml
kubectl apply -f .infrastructure/app/pv.yml
```

RBAC потрібно застосувати до Deployment, щоб ServiceAccount уже існував, коли
Deployment почне створювати Pods.

## 5. Перевірити файли до запуску

Запускай команди з кореня репозиторію:

```bash
cd /Users/a.majlo/Mate/Kuber/devops_todolist_kubernetes_task_12_rbac
```

Перевір Bash і формат змін:

```bash
bash -n bootstrap.sh
git diff --check
```

Перевір RBAC YAML:

```bash
kubectl apply --dry-run=client --validate=false -f security/rbac.yml
```

Очікувано:

```text
serviceaccount/secrets-reader created (dry run)
role.rbac.authorization.k8s.io/secrets-reader created (dry run)
rolebinding.rbac.authorization.k8s.io/secrets-reader created (dry run)
```

Перевір Deployment:

```bash
kubectl apply --dry-run=client --validate=false \
  -f .infrastructure/app/deployment.yml
```

## 6. Створити kind-кластер

Якщо навчального кластера ще немає:

```bash
kind create cluster --name todo-cluster --config cluster.yml
kubectl cluster-info --context kind-todo-cluster
kubectl get nodes
```

Якщо кластер із цим ім'ям уже існує і його потрібно створити заново, пам'ятай:
наступна команда видаляє кластер разом із його даними.

```bash
kind delete cluster --name todo-cluster
kind create cluster --name todo-cluster --config cluster.yml
```

## 7. Розгорнути проєкт

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Перевір Pods:

```bash
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
```

Якщо Deployment існував до зміни `serviceAccountName`, застосуй його ще раз і
перезапусти rollout:

```bash
kubectl apply -f .infrastructure/app/deployment.yml
kubectl rollout restart deployment/todoapp -n todoapp
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
```

## 8. Перевірити створені RBAC-ресурси

```bash
kubectl get serviceaccount secrets-reader -n todoapp
kubectl get role secrets-reader -n todoapp
kubectl get rolebinding secrets-reader -n todoapp
```

Подивитися деталі:

```bash
kubectl describe role secrets-reader -n todoapp
kubectl describe rolebinding secrets-reader -n todoapp
```

Перевірити права без curl:

```bash
kubectl auth can-i list secrets \
  --as=system:serviceaccount:todoapp:secrets-reader \
  --namespace=todoapp

kubectl auth can-i get secrets \
  --as=system:serviceaccount:todoapp:secrets-reader \
  --namespace=todoapp

kubectl auth can-i list pods \
  --as=system:serviceaccount:todoapp:secrets-reader \
  --namespace=todoapp
```

Очікування:

```text
yes
no
no
```

Це доводить принцип найменших привілеїв: акаунт може лише перелічувати Secrets.

## 9. Перевірити, що Deployment Pod використовує ServiceAccount

```bash
kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

Очікуй:

```text
secrets-reader
```

Збережи ім'я одного Deployment Pod:

```bash
POD_NAME=$(kubectl get pods -n todoapp -l app=todoapp \
  -o jsonpath='{.items[0].metadata.name}')

echo "$POD_NAME"
```

Перевір його ServiceAccount:

```bash
kubectl get pod "$POD_NAME" -n todoapp \
  -o jsonpath='{.spec.serviceAccountName}{"\n"}'
```

Очікуй `secrets-reader`.

## 10. Виконати curl із Deployment Pod

Наступна команда:

1. читає токен ServiceAccount усередині Pod;
2. викликає Kubernetes API через `curl`;
3. зберігає відповідь у тимчасовий файл;
4. показує HTTP-код і тільки назви Secrets;
5. не друкує токен або значення Secret у термінал.

```bash
kubectl exec -n todoapp "$POD_NAME" -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

STATUS=$(curl --silent --show-error \
  --cacert "$CACERT" \
  --header "Authorization: Bearer $TOKEN" \
  --output /tmp/secrets.json \
  --write-out "%{http_code}" \
  "https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/secrets")

echo "HTTP status: $STATUS"
python -c "import json; data=json.load(open(\"/tmp/secrets.json\")); print(\"Secrets:\"); [print(\"- \" + item[\"metadata\"][\"name\"]) for item in data.get(\"items\", [])]"
rm -f /tmp/secrets.json
'
```

Очікуй приблизно:

```text
HTTP status: 200
Secrets:
- app-secret
```

Кількість та імена системних Secrets можуть відрізнятися.

Не виводь у скріншот значення з `.data`: вони закодовані Base64, але все одно
можуть містити конфіденційну інформацію.

### Якщо curl повертає 403 Forbidden

Перевір:

```bash
kubectl auth can-i list secrets \
  --as=system:serviceaccount:todoapp:secrets-reader \
  -n todoapp

kubectl get rolebinding secrets-reader -n todoapp -o yaml
kubectl get pod "$POD_NAME" -n todoapp \
  -o jsonpath='{.spec.serviceAccountName}{"\n"}'
```

Найчастіші причини: різні Namespace, помилка в імені ServiceAccount або
RoleBinding посилається не на ту Role.

### Якщо всередині контейнера немає curl

Спочатку перевір:

```bash
kubectl exec -n todoapp "$POD_NAME" -- curl --version
```

Не замінюй перевірку на curl із локального комп'ютера: за умовою запит має йти
від Deployment Pod і використовувати його ServiceAccount. Якщо образ справді не
має curl, зафіксуй це в PR і узгодь із ментором спосіб перевірки або образ, який
містить curl.

## 11. Де розмістити скріншот

Скріншот потрібно прикріпити до **опису Pull Request на GitHub**, а не вставляти
в `README.md`, `INSTRUCTION.md` чи commit, якщо ментор окремо цього не просив.

Перед скріншотом виконай у терміналі:

```bash
echo "Pod: $POD_NAME"
kubectl get pod "$POD_NAME" -n todoapp \
  -o custom-columns='POD:.metadata.name,SERVICE_ACCOUNT:.spec.serviceAccountName,STATUS:.status.phase'

kubectl auth can-i list secrets \
  --as=system:serviceaccount:todoapp:secrets-reader \
  -n todoapp
```

Потім виконай curl-команду з розділу 10 і зроби скріншот так, щоб було видно:

- ім'я Pod;
- `SERVICE_ACCOUNT: secrets-reader`;
- результат `yes` від `kubectl auth can-i`;
- `HTTP status: 200`;
- список назв Secrets без їхніх значень.

Після створення PR:

1. відкрий PR;
2. натисни `Edit` біля опису;
3. додай секцію `## Validation`;
4. перетягни PNG у поле опису або встав з clipboard;
5. дочекайся, доки GitHub вставить Markdown-посилання;
6. натисни `Save`.

Приклад опису:

```markdown
## Validation

- ServiceAccount: `secrets-reader`
- `list secrets`: allowed
- `get secrets`: denied
- Kubernetes API response: HTTP 200

![RBAC validation](GitHub вставить URL зображення)
```

Не додавай локальний скріншот через `git add`, якщо завдання просить саме
attach it to the PR.

## 12. Git: перевірка, commit і push

Переглянь тільки свої зміни:

```bash
git status
git diff
```

Додай конкретні файли:

```bash
git add security/rbac.yml
git add bootstrap.sh
git add INSTRUCTION.md
```

Якщо `git diff` показує твою зміну в Deployment, додай і його:

```bash
git add .infrastructure/app/deployment.yml
```

Не використовуй `git add .`, доки не перевіриш усі файли.

Переглянь майбутній commit:

```bash
git diff --cached
git status
```

Створи commit:

```bash
git commit -m "Configure RBAC for listing secrets"
```

Поточна гілка репозиторію — `kubernetes-services`. Відправ її у свій fork:

```bash
git push -u origin kubernetes-services
```

Після push створи Pull Request:

- base repository: `mate-academy/devops_todolist_kubernetes_task_12_rbac`;
- base branch: `main`;
- head repository: `aleksandrmajlo/devops_todolist_kubernetes_task_12_rbac`;
- compare branch: `kubernetes-services`.

Додай скріншот у PR description, перевір вкладку `Files changed` і тільки після
цього прикріплюй PR до завдання на платформі.

## 13. Фінальний чекліст

- [ ] `security/rbac.yml` містить ServiceAccount, Role і RoleBinding.
- [ ] Усі три ресурси мають Namespace `todoapp`.
- [ ] Role дозволяє лише `list` для `secrets`.
- [ ] RoleBinding зв'язує Role із ServiceAccount `secrets-reader`.
- [ ] Deployment Pod використовує `serviceAccountName: secrets-reader`.
- [ ] `bootstrap.sh` застосовує RBAC після створення Namespace і до Deployment.
- [ ] `kubectl auth can-i list secrets ...` повертає `yes`.
- [ ] Curl із Deployment Pod повертає HTTP 200.
- [ ] На скріншоті немає токена або значень Secret.
- [ ] Скріншот прикріплено до опису PR.
- [ ] У PR є `security/rbac.yml`, `bootstrap.sh` та `INSTRUCTION.md`.
