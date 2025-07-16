# Домашнее задание к занятию «Управление доступом»

### Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Чеклист готовности к домашнему заданию

1. Установлено k8s-решение, например MicroK8S.
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым github-репозиторием.

------

### Инструменты / дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) RBAC.
2. [Пользователи и авторизация RBAC в Kubernetes](https://habr.com/ru/company/flant/blog/470503/).
3. [RBAC with Kubernetes in Minikube](https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b).

------

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.
2. Настройте конфигурационный файл kubectl для подключения.
3. Создайте роли и все необходимые настройки для пользователя.
4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.

------

## Решение

### Задание 1. Создайте конфигурацию для подключения пользователя

Генерируем ключ и запрос на выпуск сертификата

```
openssl genrsa -out sergey.key 4096

openssl req -new -key sergey.key -out sergey.csr -subj "/CN=sergey/O=netology"

cat sergey.csr | base64 -w 0 > sergey.csr.b64
```

Добавляем csr в манифест и применяем его, администратор подписывает запрос и выгружает сертификат.

request.yml

```yaml
---
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: sergey-csr
spec:
  groups:
    - system:authenticated
  request: ........
  expirationSeconds: 86400
  usages:
    - client auth
  signerName: kubernetes.io/kube-apiserver-client
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl apply -f request.yml 
certificatesigningrequest.certificates.k8s.io/sergey-csr created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl get certificatesigningrequest
NAME         AGE   SIGNERNAME                            REQUESTOR   REQUESTEDDURATION   CONDITION
sergey-csr   12s   kubernetes.io/kube-apiserver-client   admin       24h                 Pending

sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl get csr sergey-csr -o jsonpath={.status.certificate} | base64 --decode > sergey.crt
```

Создаем пользователя и контекст в конфигурацию kubectl

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl config set-credentials sergey --client-certificate sergey.crt --client-key sergey.key --embed-certs=true

sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl config set-context sergey_context --cluster=microk8s-cluster --user=sergey

sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl config get-contexts
CURRENT   NAME             CLUSTER            AUTHINFO   NAMESPACE
*         microk8s         microk8s-cluster   admin      
          sergey_context   microk8s-cluster   sergey  
```

namespace.yml
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: netology
  namespace: netology
```

rbac.yml

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: sergey
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-rb
  namespace: sergey
subjects:
  - kind: User
    name: sergey
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl apply -f namespace.yml 
namespace/sergey created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl apply -f rbac.yml 
role.rbac.authorization.k8s.io/pod-reader created
rolebinding.rbac.authorization.k8s.io/pod-reader-rb created
```

Проверяем права

deployment.yml

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: sergey
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest

---
apiVersion: v1
kind: Service
metadata:
  namespace: sergey
  name: nginx-svc
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
  - name: web
    port: 80
    protocol: TCP
    nodePort: 30080
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl apply -f deployment.yml -n sergey
deployment.apps/nginx created
service/nginx-svc created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl config use-context sergey_context
Switched to context "sergey_context".



sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl get pods -n sergey
NAME                     READY   STATUS    RESTARTS   AGE
nginx-54c98b4f84-zfbtb   1/1     Running   0          3m28s



sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl describe pod -n sergey nginx-54c98b4f84-zfbtb

Name:             nginx-54c98b4f84-zfbtb
Namespace:        sergey
Priority:         0
Service Account:  default
Node:             netology-01/192.168.73.128
Start Time:       Wed, 16 Jul 2025 21:53:05 +0700
Labels:           app=nginx
                  pod-template-hash=54c98b4f84
Annotations:      cni.projectcalico.org/containerID: 7b1fdd24e8c9c8893c9311bfea4bafe92a4440d89b66696795e84886994f07c4
                  cni.projectcalico.org/podIP: 10.1.123.158/32
                  cni.projectcalico.org/podIPs: 10.1.123.158/32
Status:           Running
IP:               10.1.123.158
IPs:
  IP:           10.1.123.158
Controlled By:  ReplicaSet/nginx-54c98b4f84
Containers:
  nginx:
    Container ID:   containerd://e8a58c6c1def8c5ff522a8ed2ae15c641117f57c275196e73dda57be7b26bb60
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:f5c017fb33c6db484545793ffb67db51cdd7daebee472104612f73a85063f889
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 16 Jul 2025 21:53:08 +0700
    Ready:          True

....
....
....


sergey@netology-01:~/Work/netology-devops/k8s/k8s-09$ kubectl logs -n sergey nginx-54c98b4f84-zfbtb

/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/07/16 14:53:08 [notice] 1#1: using the "epoll" event method
2025/07/16 14:53:08 [notice] 1#1: nginx/1.29.0
2025/07/16 14:53:08 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14+deb12u1) 
2025/07/16 14:53:08 [notice] 1#1: OS: Linux 6.11.0-26-generic
2025/07/16 14:53:08 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2025/07/16 14:53:08 [notice] 1#1: start worker processes
2025/07/16 14:53:08 [notice] 1#1: start worker process 30
2025/07/16 14:53:08 [notice] 1#1: start worker process 31
2025/07/16 14:53:08 [notice] 1#1: start worker process 32
2025/07/16 14:53:08 [notice] 1#1: start worker process 33
2025/07/16 14:53:08 [notice] 1#1: start worker process 34
2025/07/16 14:53:08 [notice] 1#1: start worker process 35

```
