# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

------

## Решение

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netology-deployment
  labels:
    app: nginx_multy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx_multy
  template:
    metadata:
      labels:
        app: nginx_multy
    spec:
      containers:
      - name: multytools
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "8080"
          - name: HTTPS_PORT
            value: "11443"
        ports:
          - name: http-port
            containerPort: 8080
          - name: https-ports
            containerPort: 11443
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```
```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl apply -f depl.yml 
deployment.apps/netology-deployment created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl get deployment
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
netology-deployment   3/3     3            3           36s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
netology-deployment-89c69d45d-9vg97   2/2     Running   0          41s
netology-deployment-89c69d45d-nk9kx   2/2     Running   0          41s
netology-deployment-89c69d45d-wbsgg   2/2     Running   0          41s
```

multitool

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multitool
spec:
  containers:
  - name: multitool
    image: wbitt/network-multitool
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl apply -f multi.yml 
pod/multitool created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
multitool                             1/1     Running   0          7s
netology-deployment-89c69d45d-9vg97   2/2     Running   0          5m11s
netology-deployment-89c69d45d-nk9kx   2/2     Running   0          5m11s
netology-deployment-89c69d45d-wbsgg   2/2     Running   0          5m11s
```

service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: network-multitool
spec:
  selector:
    app: nginx_multy
  ports:
    - name: nginx-port
      protocol: TCP
      port: 9001
      targetPort: 80
    - name: multitool
      protocol: TCP
      port: 9002
      targetPort: 8080
  type: ClusterIP
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl apply -f service-1.yml 
service/network-multitool created

sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl get svc
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
kubernetes          ClusterIP   10.152.183.1     <none>        443/TCP             10h
network-multitool   ClusterIP   10.152.183.100   <none>        9001/TCP,9002/TCP   9s
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl exec -it multitool -- bash

multitool:/# curl 10.152.183.100:9001

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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


multitool:/# curl 10.152.183.100:9002

WBITT Network MultiTool (with NGINX) - netology-deployment-89c69d45d-nk9kx - 10.1.123.145 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
```

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: network-multitool
spec:
  selector:
    app: nginx_multy
  ports:
    - name: nginx-port
      protocol: TCP
      port: 80
      nodePort: 30001
    - name: multitool
      protocol: TCP
      port: 8080
      nodePort: 30002
  type: NodePort
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl apply -f service-2.yml 
service/network-multitool configured

sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ kubectl get svc
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
kubernetes          ClusterIP   10.152.183.1     <none>        443/TCP                       10h
network-multitool   NodePort    10.152.183.100   <none>        80:30001/TCP,8080:30002/TCP   4m57s
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ curl localhost:30001
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-04$ curl localhost:30002

WBITT Network MultiTool (with NGINX) - netology-deployment-89c69d45d-9vg97 - 10.1.123.144 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
```