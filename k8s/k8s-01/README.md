# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

### Цель задания

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

------

### Чеклист готовности к домашнему заданию

1. Личный компьютер с ОС Linux или MacOS 

или

2. ВМ c ОС Linux в облаке либо ВМ на локальной машине для установки MicroK8S  

------

### Инструкция к заданию

1. Установка MicroK8S:
    - sudo apt update,
    - sudo apt install snapd,
    - sudo snap install microk8s --classic,
    - добавить локального пользователя в группу `sudo usermod -a -G microk8s $USER`,
    - изменить права на папку с конфигурацией `sudo chown -f -R $USER ~/.kube`.

2. Полезные команды:
    - проверить статус `microk8s status --wait-ready`;
    - подключиться к microK8s и получить информацию можно через команду `microk8s command`, например, `microk8s kubectl get nodes`;
    - включить addon можно через команду `microk8s enable`; 
    - список addon `microk8s status`;
    - вывод конфигурации `microk8s config`;
    - проброс порта для подключения локально `microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443`.

3. Настройка внешнего подключения:
    - отредактировать файл /var/snap/microk8s/current/certs/csr.conf.template
    ```shell
    # [ alt_names ]
    # Add
    # IP.4 = 123.45.67.89
    ```
    - обновить сертификаты `sudo microk8s refresh-certs --cert front-proxy-client.crt`.

4. Установка kubectl:
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl;
    - chmod +x ./kubectl;
    - sudo mv ./kubectl /usr/local/bin/kubectl;
    - настройка автодополнения в текущую сессию `bash source <(kubectl completion bash)`;
    - добавление автодополнения в командную оболочку bash `echo "source <(kubectl completion bash)" >> ~/.bashrc`.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**.
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**.

------

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.

------

### Задание 2. Установка и настройка локального kubectl
1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
3. Подключиться к дашборду с помощью port-forward.

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get nodes` и скриншот дашборда.

------

## Решение

### Задание 1. Установка MicroK8S

#### Установка MicroK8S

```
sergey@netology-01:~$ sudo apt install snapd
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
snapd is already the newest version (2.67.1+24.04).
snapd set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 2 not upgraded.
```

```
ergey@netology-01:~$ microk8s.status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
  disabled:
    cert-manager         # (core) Cloud native certificate management
    cis-hardening        # (core) Apply CIS K8s hardening
    community            # (core) The community addons repository
    dashboard            # (core) The Kubernetes dashboard
    gpu                  # (core) Alias to nvidia add-on
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
    minio                # (core) MinIO object storage
    nvidia               # (core) NVIDIA hardware (GPU and network) support
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    rbac                 # (core) Role-Based Access Control for authorisation
    registry             # (core) Private image registry exposed on localhost:32000
    rook-ceph            # (core) Distributed Ceph storage using Rook
    storage              # (core) Alias to hostpath-storage add-on, deprecated
```

#### Установка dashboard

```
sergey@netology-01:~$ microk8s enable dashboard
Infer repository core for addon dashboard
Enabling Kubernetes Dashboard
Infer repository core for addon metrics-server
Enabling Metrics-Server
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrolebinding.rbac.authorization.k8s.io/microk8s-admin created
Metrics-Server is enabled
Applying manifest
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
secret/microk8s-dashboard-token created

If RBAC is not enabled access the dashboard using the token retrieved with:

microk8s kubectl describe secret -n kube-system microk8s-dashboard-token

Use this token in the https login UI of the kubernetes-dashboard service.

In an RBAC enabled setup (microk8s enable RBAC) you need to create a user with restricted
permissions as shown in:
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
```

#### Установленные сервисы

```
sergey@netology-01:~$ microk8s kubectl get all -A
NAMESPACE     NAME                                             READY   STATUS    RESTARTS   AGE
kube-system   pod/calico-kube-controllers-5947598c79-64b2l     1/1     Running   0          11m
kube-system   pod/calico-node-vdp7b                            1/1     Running   0          11m
kube-system   pod/coredns-79b94494c7-qzq89                     1/1     Running   0          11m
kube-system   pod/dashboard-metrics-scraper-5bd45c9dd6-xsxl7   1/1     Running   0          77s
kube-system   pod/kubernetes-dashboard-57bc5f89fb-574rh        1/1     Running   0          78s
kube-system   pod/metrics-server-7dbd8b5cc9-ss6jg              1/1     Running   0          80s

NAMESPACE     NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes                  ClusterIP   10.152.183.1     <none>        443/TCP                  11m
kube-system   service/dashboard-metrics-scraper   ClusterIP   10.152.183.254   <none>        8000/TCP                 78s
kube-system   service/kube-dns                    ClusterIP   10.152.183.10    <none>        53/UDP,53/TCP,9153/TCP   11m
kube-system   service/kubernetes-dashboard        ClusterIP   10.152.183.107   <none>        443/TCP                  78s
kube-system   service/metrics-server              ClusterIP   10.152.183.181   <none>        443/TCP                  80s

NAMESPACE     NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/calico-node   1         1         1       1            1           kubernetes.io/os=linux   11m

NAMESPACE     NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/calico-kube-controllers     1/1     1            1           11m
kube-system   deployment.apps/coredns                     1/1     1            1           11m
kube-system   deployment.apps/dashboard-metrics-scraper   1/1     1            1           77s
kube-system   deployment.apps/kubernetes-dashboard        1/1     1            1           78s
kube-system   deployment.apps/metrics-server              1/1     1            1           80s

NAMESPACE     NAME                                                   DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/calico-kube-controllers-5947598c79     1         1         1       11m
kube-system   replicaset.apps/coredns-79b94494c7                     1         1         1       11m
kube-system   replicaset.apps/dashboard-metrics-scraper-5bd45c9dd6   1         1         1       77s
kube-system   replicaset.apps/kubernetes-dashboard-57bc5f89fb        1         1         1       78s
kube-system   replicaset.apps/metrics-server-7dbd8b5cc9              1         1         1       80s
```

#### Сертификат

```
sergey@netology-01:~$ microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443

sergey@netology-01:~$ sudo microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/8148/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.
```

### Установка и настройка kubectl

```
sergey@netology-01:~$ sudo snap install kubectl --classic
kubectl 1.33.2 from Canonical✓ installed
```

```
sergey@netology-01:~$ microk8s config > ~/.kube/config

sergey@netology-01:~$ kubectl version
Client Version: v1.33.2
Kustomize Version: v5.6.0
Server Version: v1.32.3
```

```
gey@netology-01:~$ kubectl get nodes
NAME          STATUS   ROLES    AGE   VERSION
netology-01   Ready    <none>   17m   v1.32.3
```

![](2025-07-15-13-39-42.png)

```
ergey@netology-01:~$ sudo microk8s kubectl describe secret -n kube-system microk8s-dashboard-token
[sudo] password for sergey: 
Name:         microk8s-dashboard-token
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 93c6855f-9daf-469f-934b-efaf4e055dd3

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1123 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InNEZWIyUjlja3NsdktFdHVkZ1RvMVVJbGowNGZHNnlXU3J6TzNOTGdxa3cifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJtaWNyb2s4cy1kYXNoYm9hcmQtdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjkzYzY4NTVmLTlkYWYtNDY5Zi05MzRiLWVmYWY0ZTA1NWRkMyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkZWZhdWx0In0.G7CB1QaiEL0WRme0_K2DgMQUq104wdYldosX12jmvIAmQSN1HdtH6LTiV9hx17NbOuq-LDxjaZxvjWpao4hiGYjSehw451d8B9KJcB7xaak8mV_wWrA_EEaq7ovDr_TVmHOf7TLjSb3BjDQ5PhgWNFrReQBgfeFmSHFVIQgs6_YfbNhLbooE_fW9XMcWOqI2JplT_beU9G02wABQw13vQUDqvCfJL4RUdxmRBrmOSuCpvUzs8zSwP6HcG2NtCBh3UcFOAIjZ6qyQ8f-rZEtTB_wzbpa_dzai_tNZhLrMGzATj46wzt9DwU5NdfOJdlayhts4EeW9LG2UYDgAyH-1Rg
```

![](2025-07-15-13-43-53.png)

