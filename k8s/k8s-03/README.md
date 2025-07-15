# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------

## Решение

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

Создание пространства имён

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: netology
  namespace: netology
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get ns
NAME              STATUS   AGE
default           Active   8h
kube-node-lease   Active   8h
kube-public       Active   8h
kube-system       Active   8h

sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f namestace.yml 
namespace/netology created

sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get ns
NAME              STATUS   AGE
default           Active   8h
kube-node-lease   Active   8h
kube-public       Active   8h
kube-system       Active   8h
netology          Active   3s
```

Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-nginx-multitool
  namespace: netology
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.2
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "1180"
```

Для решения ошибки использован порт 1180

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f deployment.yml 
deployment.apps/dpl-nginx-multitool created

sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get po -n netology -o wide
NAME                                   READY   STATUS              RESTARTS   AGE   IP       NODE          NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-57fd9df97f-zvtrr   0/2     ContainerCreating   0          27s   <none>   netology-01   <none>           <none>

sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get po -n netology -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-57fd9df97f-zvtrr   2/2     Running   0          49s   10.1.123.136   netology-01   <none>           <none>
```

Запросы контейнерам

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology dpl-nginx-multitool-57fd9df97f-zvtrr -- curl localhost:1180
Defaulted container "nginx" out of: nginx, multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   155  100   155    0  WBITT Network MultiTool (with NGINX) - dpl-nginx-multitool-57fd9df97f-zvtrr - 10.1.123.136 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
   0  22142      0 --:--:-- --:--:-- --:--:-- 22142
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology dpl-nginx-multitool-57fd9df97f-zvtrr -- curl localhost:80
Defaulted container "nginx" out of: nginx, multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   612  100   612    0     0  68000      0 --:--:-- --:--:-- --:--:-- 76500
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology dpl-nginx-multitool-57fd9df97f-zvtrr -- curl localhost:443
Defaulted container "nginx" out of: nginx, multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   255  100   255    0     0  42500      0 --:--:-- --:--:-- --:--:-- 51000
<html>
<head><title>400 The plain HTTP request was sent to HTTPS port</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<center>The plain HTTP request was sent to HTTPS port</center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
```

Увеличиваем колличество реплик и перезапускаем Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-nginx-multitool
  namespace: netology
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.2
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "1180"
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f deployment.yml 
deployment.apps/dpl-nginx-multitool configured


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get po -n netology -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-57fd9df97f-29hbv   2/2     Running   0          5s      10.1.123.137   netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-zvtrr   2/2     Running   0          6m13s   10.1.123.136   netology-01   <none>           <none>
```

Создание service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx-multitool
  namespace: netology
spec:
  ports:
    - name: http-app
      port: 80
      protocol: TCP
      targetPort: 80
    - name: https-app
      port: 443
      protocol: TCP
      targetPort: 443
    - name: http-multitool
      port: 1180
      protocol: TCP
      targetPort: 1180
  selector:
    app: web
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f service.yml 
service/svc-nginx-multitool created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get svc -n netology -o wide
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE   SELECTOR
svc-nginx-multitool   ClusterIP   10.152.183.175   <none>        80/TCP,443/TCP,1180/TCP   29s   app=web


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get ep -n netology -o wide
NAME                  ENDPOINTS                                                          AGE
svc-nginx-multitool   10.1.123.136:1180,10.1.123.137:1180,10.1.123.136:443 + 3 more...   58s
```
Создать отдельный Pod с приложением multitool и убедиться с помощью curl, что из пода есть доступ до приложений из п.1.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: only-multitool
  namespace: netology
spec:
  containers:
    - image: wbitt/network-multitool
      name: nginx
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f multitool.yml 
pod/only-multitool created
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology only-multitool -- curl svc-nginx-multitool:80  
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   612  100   612    0     0  89057      0 --:--:-- --:--:-- --:--:--   99k
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology only-multitool -- curl svc-nginx-multitool:443
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   255  100   255    0     0  48906      0 -<html>- --:--:-- --:--:--     0
<head><title>400 The plain HTTP request was sent to HTTPS port</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<center>The plain HTTP request was sent to HTTPS port</center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
-:--:-- --:--:-- --:--:-- 63750
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology only-multitool -- curl svc-nginx-multitool:1180
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    WBITT Network MultiTool (with NGINX) - dpl-nginx-multitool-57fd9df97f-zvtrr - 10.1.123.136 - HTTP: 1180 , HTTPS: 443 . (Formerly praqma/network-multitool)
100   155  100   155    0     0  27351      0 --:--:-- --:--:-- --:--:-- 38750
```

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-init
  namespace: netology
spec:
  replicas: 1 
  selector:
    matchLabels:
      app: init
  template:
    metadata:
      labels:
        app: init
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.2
      initContainers:
      - name: busybox
        image: busybox
        command: ['sleep', '30']
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f init.yml 
deployment.apps/dpl-init created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get po -n netology -o wide
NAME                                   READY   STATUS     RESTARTS   AGE    IP             NODE          NOMINATED NODE   READINESS GATES
dpl-init-6fb7d54b5-2ffdz               0/1     Init:0/1   0          2s     <none>         netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-29hbv   2/2     Running    0          10m    10.1.123.137   netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-zvtrr   2/2     Running    0          17m    10.1.123.136   netology-01   <none>           <none>
only-multitool                         1/1     Running    0          4m4s   10.1.123.138   netology-01   <none>           <none>


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get po -n netology -o wide
NAME                                   READY   STATUS     RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
dpl-init-6fb7d54b5-2ffdz               0/1     Init:0/1   0          20s     10.1.123.139   netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-29hbv   2/2     Running    0          11m     10.1.123.137   netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-zvtrr   2/2     Running    0          17m     10.1.123.136   netology-01   <none>           <none>
only-multitool                         1/1     Running    0          4m22s   10.1.123.138   netology-01   <none>           <none>


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get po -n netology -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
dpl-init-6fb7d54b5-2ffdz               1/1     Running   0          41s     10.1.123.139   netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-29hbv   2/2     Running   0          11m     10.1.123.137   netology-01   <none>           <none>
dpl-nginx-multitool-57fd9df97f-zvtrr   2/2     Running   0          17m     10.1.123.136   netology-01   <none>           <none>
only-multitool                         1/1     Running   0          4m43s   10.1.123.138   netology-01   <none>           <none>
```

Создаие и запуск Service 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-init
  namespace: netology
spec:
  ports:
    - name: http-app
      port: 80 
  selector:
    app: init
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get svc -n netology -o wide
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE   SELECTOR
svc-nginx-multitool   ClusterIP   10.152.183.175   <none>        80/TCP,443/TCP,1180/TCP   11m   app=web


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl apply -f svc-init.yml 
service/svc-init created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl get svc -n netology -o wide
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE   SELECTOR
svc-init              ClusterIP   10.152.183.158   <none>        80/TCP                    3s    app=init
svc-nginx-multitool   ClusterIP   10.152.183.175   <none>        80/TCP,443/TCP,1180/TCP   11m   app=web
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-03$ kubectl exec -n netology dpl-init-6fb7d54b5-2ffdz -- curl svc-init:80
Defaulted container "nginx" out of: nginx, busybox (init)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0  76500      0 --:--:-- --:--:-- --:--:-- 76500
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

