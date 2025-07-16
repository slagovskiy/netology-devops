# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

## Решение

### Создать Deployment приложения, использующего локальный PV, созданный вручную.

pv.yml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume
spec:
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/spam
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl apply -f pv.yml 
persistentvolume/pv-volume created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-volume   10Mi       RWO            Retain           Available                          <unset>                          47s
```

pvc.yml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-volume
spec:
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Mi
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl apply -f pvc.yml 
persistentvolumeclaim/pvc-volume created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-volume   10Mi       RWO            Retain           Bound    default/pvc-volume                  <unset>                          2m26s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pvc
NAME         STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-volume   Bound    pv-volume   10Mi       RWO                           <unset>                 13s
```

deployment.yml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
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
        persistentVolumeClaim:
          claimName: pvc-volume
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl apply -f deployment.yml 
deployment.apps/deployment created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-volume   10Mi       RWO            Retain           Bound    default/pvc-volume                  <unset>                          3m55s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pvc
NAME         STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-volume   Bound    pv-volume   10Mi       RWO                           <unset>                 96s
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl exec -it -c watcher deployment-58f8d9c8dd-d5tvb -- bash

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 07:46:17 UTC 2025

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 07:46:22 UTC 2025

bash-5.1# cat /spam/what_time_is_it.txt 
Wed Jul 16 07:46:27 UTC 2025
```

После удаления deployment и pvc, pv перешёл в статус released, так как он больше не привязан

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl delete deployment.apps deployment
deployment.apps "deployment" deleted

sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl delete pvc pvc-volume
persistentvolumeclaim "pvc-volume" deleted

sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-volume   10Mi       RWO            Retain           Released   default/pvc-volume                  <unset>                          8m30s
```

После удаления pv файл сохраняется, согласно сделанным настройкам.

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl delete pv pv-volume
persistentvolume "pv-volume" deleted

sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ ls /tmp/spam/
what_time_is_it.txt
```

### Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

Предварительная настройка

```
sudo microk8s enable community

sudo microk8s enable nfs

sudo apt install nfs-common
```

В кластере появляется поддержка nfs.

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get sc
NAME   PROVISIONER                            RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-provisioner   Delete          Immediate           true                   85s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pods -n nfs-server-provisioner
NAME                       READY   STATUS    RESTARTS   AGE
nfs-server-provisioner-0   1/1     Running   0          2m17s
```

deployment-nfs.yml

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs-deployment
  template:
    metadata:
      labels:
        app: nfs-deployment
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
        - mountPath: /test
          name: test
      volumes:
      - name: test
        persistentVolumeClaim:
          claimName: nfs-pvc

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  storageClassName: nfs
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Mi
```

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl apply -f deployment-nfs.yml 
deployment.apps/nfs-deployment created
persistentvolumeclaim/nfs-pvc created


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
nfs-deployment-77ff5d965c-bl87d   1/1     Running   0          12s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pvc
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
nfs-pvc   Bound    pvc-2520cc37-c1f0-4214-a353-ddb16d1c357c   2Mi        RWO            nfs            <unset>                 23s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
data-nfs-server-provisioner-0              1Gi        RWO            Retain           Bound    nfs-server-provisioner/data-nfs-server-provisioner-0                  <unset>                          5m8s
pvc-2520cc37-c1f0-4214-a353-ddb16d1c357c   2Mi        RWO            Delete           Bound    default/nfs-pvc                                        nfs            <unset>                          34s


sergey@netology-01:~/Work/netology-devops/k8s/k8s-07$ kubectl exec -it nfs-deployment-77ff5d965c-bl87d -c multitool -- bash

nfs-deployment-77ff5d965c-bl87d:/# echo "TEST" > /test/test_file.txt

nfs-deployment-77ff5d965c-bl87d:/# cat /test/test_file.txt 
TEST

nfs-deployment-77ff5d965c-bl87d:/# exit
exit
```