# Домашнее задание к занятию «Базовые объекты K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера. 

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. Описание [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) и примеры манифестов.
2. Описание [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

------

### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

------

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get pods`, а также скриншот результата подключения.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------

### Критерии оценки
Зачёт — выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку — задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки.


------

## Решение

### Создать Pod с именем hello-world

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
  labels: 
    app: nginx
spec:
  containers:
  - name: nginx
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl apply -f pod.yml 
pod/hello-world created
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          96s
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ curl localhost:38080


Hostname: hello-world

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:38080  
	user-agent=curl/8.5.0  

Request Body:
	-no body in request-
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl delete pods/hello-world
pod "hello-world" deleted
```

### Создать Service и подключить его к Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app: echoserver
spec:
  containers:
  - image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    name: echoserver
    ports:
    - containerPort: 8080
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  ports:
  - name: echoserver
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: echoserver
```


```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl get pods
No resources found in default namespace.
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl apply -f pod_2.yml 
pod/netology-web created
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
netology-web   1/1     Running   0          10s
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl apply -f svc.yml 
service/netology-svc created
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ kubectl get services
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes     ClusterIP   10.152.183.1     <none>        443/TCP    116m
netology-svc   ClusterIP   10.152.183.220   <none>        8080/TCP   22s
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-02$ curl 10.152.183.220:8080


Hostname: netology-web

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=192.168.73.128
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://10.152.183.220:8080/

Request Headers:
	accept=*/*  
	host=10.152.183.220:8080  
	user-agent=curl/8.5.0  

Request Body:
	-no body in request-
```
