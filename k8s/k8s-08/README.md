# Домашнее задание к занятию «Конфигурация приложений»

### Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8s).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым GitHub-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/configuration/secret/) Secret.
2. [Описание](https://kubernetes.io/docs/concepts/configuration/configmap/) ConfigMap.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.
3. Продемонстрировать, что pod стартовал и оба конейнера работают.
4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Создать Deployment приложения, состоящего из Nginx.
2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.
4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

## Решение

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

deployment.yml
с учетом конфликта портов, страница берется из конфигурации

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ports
data:
  HTTP_PORT: "8080"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: files
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="UTF-8">
    <title>Пример базовой структуры HTML</title>
    </head>
    <body>
    <h1>Заголовок страницы</h1>
    <p>Это пример абзаца текста в HTML-документе.</p>
    </body>
    </html>

---
apiVersion: apps/v1
kind: Deployment
metadata:
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
        volumeMounts:
        - name: index
          mountPath: /usr/share/nginx/html
      - name: multitool
        image: praqma/network-multitool
        envFrom:
        - configMapRef:
            name: ports
      volumes:
      - name: index
        configMap:
          name: files

---
apiVersion: v1
kind: Service
metadata:
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
sergey@netology-01:~/Work/netology-devops/k8s/k8s-08$ kubectl apply -f deployment.yml 
configmap/ports created
configmap/files created
deployment.apps/nginx created
service/nginx-svc created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-08$ kubectl get configmap
NAME               DATA   AGE
files              1      27s
kube-root-ca.crt   1      28h
ports              1      28s
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-08$ curl http://localhost:30080/
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Пример базовой структуры HTML</title>
</head>
<body>
<h1>Заголовок страницы</h1>
<p>Это пример абзаца текста в HTML-документе.</p>
</body>
</html>
```

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

выпуск сертификата

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-08$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=test.app.local/O=test.app.local"

..+.+........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*...+...+..+.+..+............+.+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+......+.+........+......+........................+.........+.+.........+..+......+...+.........+...+....+......+........+.+.....+................+.....+...+............+...+......+....+..+....+.....+....+.........+...+..+.+.....+.+...+............+...........+............+...+....+....................+...+...+.......+..+.........+.+...+.....+.+..............+............+.+........+.+..............+......+..................+.......+.....+......+....+......+.....+...+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.+.....+.........+.........+.+......+...+..+....+......+.....+..........+..............+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+......+.....+....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+.+......+........+...+....+........+.+..+...+....+..+................+..+.+..+...+....+...+..+......+......+.+...+..+............+...............+.+.........+...+..+.+..........................+.+...+.....+....+.....+...+.......+......+.........+........+..................+....+...+..+...+.............+......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
```


deployment_tls.yml


```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ports
data:
  HTTP_PORT: "8080"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: files
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="UTF-8">
    <title>Пример базовой структуры HTML</title>
    </head>
    <body>
    <h1>Заголовок страницы</h1>
    <p>Это пример абзаца текста в HTML-документе.</p>
    </body>
    </html>

---
apiVersion: apps/v1
kind: Deployment
metadata:
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
        volumeMounts:
        - name: index
          mountPath: /usr/share/nginx/html
      - name: multitool
        image: praqma/network-multitool
        envFrom:
        - configMapRef:
            name: ports
      volumes:
      - name: index
        configMap:
          name: files

---
apiVersion: v1
kind: Secret
metadata:
  name: nginx-tls
type: kubernetes.io/tls
data:
  tls.crt: |
    ......

  tls.key: |
    ......


---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
  - name: nginx
    protocol: TCP
    port: 80
    targetPort: 80
  selector:
    app: nginx

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: test.app.local
    http:
      paths:
        - path: /
          pathType: ImplementationSpecific
          backend: 
            service:
              name: nginx
              port:
                number: 80
  tls:
    - hosts:
      - test.app.local
      secretName: nginx-tls
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-08$ curl --insecure --header "host: test.app.local" https://localhost

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Пример базовой структуры HTML</title>
</head>
<body>
<h1>Заголовок страницы</h1>
<p>Это пример абзаца текста в HTML-документе.</p>
</body>
</html>
```