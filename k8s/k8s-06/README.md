# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

------

## Решение

### Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

Контейнер с busybox пишет в файл what_time_is_it.txt время c интервалом в 5 секунд. В контейнере с multitool можно получить значение из этого файла в общей директории /spam

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spam-deployment
  labels:
    app: spam
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spam
  template:
    metadata:
      labels:
        app: spam
    spec:
      containers:
      - name: spammer
        image: busybox
        command: ['sh', '-c', "while true; do echo $(date) > /spam/what_time_is_it.txt; sleep 5; done"]
        volumeMounts:
        - name: sharing
          mountPath: /spam
      - name: watcher
        image: praqma/network-multitool
        volumeMounts:
        - name: sharing
          mountPath: /spam
      volumes:
      - name: sharing
        emptyDir: {}
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-06$ kubectl apply -f dep.yml 
deployment.apps/spam-deployment created

sergey@netology-01:~/Work/netology-devops/k8s/k8s-06$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
spam-deployment-b8f999679-rgvcs   2/2     Running   0          9s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-06$ kubectl exec -c watcher -it spam-deployment-b8f999679-rgvcs -- bash

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 06:23:46 UTC 2025

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 06:23:56 UTC 2025

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 06:24:06 UTC 2025

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 06:24:11 UTC 2025
```

### Создать DaemonSet приложения, которое может прочитать логи ноды.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-daemon
  labels:
    app: log
spec:
  selector:
    matchLabels:
      app: log
  template:
    metadata:
      labels:
        app: log
    spec:
      containers:
      - name: reader
        image: praqma/network-multitool
        volumeMounts:
        - name: sharing
          mountPath: /outsider-logs
      volumes:
      - name: sharing
        hostPath:
          path: /var/log/syslog
```

Подключаемся к поду и видим следующие логи

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-06$ kubectl apply -f dae.yml 
daemonset.apps/log-daemon created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-06$ kubectl get pods
NAME                              READY   STATUS              RESTARTS   AGE
log-daemon-pknxs                  0/1     ContainerCreating   0          4s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-06$ kubectl exec -it log-daemon-pknxs -- bash

bash-5.1# tail outsider-logs 

2025-07-16T13:27:27.875051+07:00 netology-01 microk8s.daemon-containerd[210984]: time="2025-07-16T13:27:27.873694769+07:00" level=info msg="ImageUpdate event &ImageUpdate{Name:docker.io/praqma/network-multitool:latest,Labels:map[string]string{io.cri-containerd.image: managed,},XXX_unrecognized:[],}"
2025-07-16T13:27:27.881555+07:00 netology-01 microk8s.daemon-containerd[210984]: time="2025-07-16T13:27:27.881251070+07:00" level=info msg="PullImage \"praqma/network-multitool:latest\" returns image reference \"sha256:1631e536ed7dd2e8b80119f4f54c7958da9ffc159323ae5ecfb15c76ebdab10a\""
2025-07-16T13:27:27.887094+07:00 netology-01 microk8s.daemon-containerd[210984]: time="2025-07-16T13:27:27.886803845+07:00" level=info msg="CreateContainer within sandbox \"8bdaa2bf10229693cada92aaed6d74452a55a26d8742b70a442831f96dfce6db\" for container &ContainerMetadata{Name:reader,Attempt:0,}"
2025-07-16T13:27:27.942592+07:00 netology-01 microk8s.daemon-containerd[210984]: time="2025-07-16T13:27:27.942044987+07:00" level=info msg="CreateContainer within sandbox \"8bdaa2bf10229693cada92aaed6d74452a55a26d8742b70a442831f96dfce6db\" for &ContainerMetadata{Name:reader,Attempt:0,} returns container id \"8d09184fedac3b198577f13e5eb90ba46baa422c5a92854af5d10155cc8e62ad\""
2025-07-16T13:27:27.944662+07:00 netology-01 microk8s.daemon-containerd[210984]: time="2025-07-16T13:27:27.944381318+07:00" level=info msg="StartContainer for \"8d09184fedac3b198577f13e5eb90ba46baa422c5a92854af5d10155cc8e62ad\""
2025-07-16T13:27:27.982797+07:00 netology-01 systemd[1]: var-snap-microk8s-common-var-lib-containerd-tmpmounts-containerd\x2dmount2885744598.mount: Deactivated successfully.
2025-07-16T13:27:28.218491+07:00 netology-01 microk8s.daemon-containerd[210984]: time="2025-07-16T13:27:28.217892292+07:00" level=info msg="StartContainer for \"8d09184fedac3b198577f13e5eb90ba46baa422c5a92854af5d10155cc8e62ad\" returns successfully"
2025-07-16T13:27:28.684530+07:00 netology-01 systemd[1832]: Started snap.kubectl.kubectl-f0549d9a-d6fd-4916-848a-cb5285cd7875.scope.
2025-07-16T13:27:29.105598+07:00 netology-01 microk8s.daemon-kubelite[238126]: I0716 13:27:29.103353  238126 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="default/log-daemon-pknxs" podStartSLOduration=3.17537287 podStartE2EDuration="5.103314078s" podCreationTimestamp="2025-07-16 13:27:24 +0700 +07" firstStartedPulling="2025-07-16 13:27:25.955712595 +0700 +07 m=+45663.081935028" lastFinishedPulling="2025-07-16 13:27:27.883653803 +0700 +07 m=+45665.009876236" observedRunningTime="2025-07-16 13:27:29.099790331 +0700 +07 m=+45666.226016264" watchObservedRunningTime="2025-07-16 13:27:29.103314078 +0700 +07 m=+45666.229539511"
2025-07-16T13:28:04.195077+07:00 netology-01 systemd[1832]: Started snap.kubectl.kubectl-2362d19a-ed63-4c4b-9e46-5bd99dcaedb5.scope.
```