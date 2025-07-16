# Домашнее задание к занятию «Helm»

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение, например, MicroK8S.
2. Установленный локальный kubectl.
3. Установленный локальный Helm.
4. Редактор YAML-файлов с подключенным репозиторием GitHub.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

## Решение

### Задание 1. Подготовить Helm-чарт для приложения

Основные файлы

deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.deployment.name }}
  labels: 
    {{- toYaml .Values.deploymentLabels | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels: 
      {{- toYaml .Values.podLabels | nindent 6 }}
  template:
    metadata:
      labels: 
        {{- toYaml .Values.podLabels | nindent 8 }}
    spec:
      containers:
      - name: {{ .Values.image.name }}
        image: {{ .Values.image.repository }}
```

service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
spec:
  selector:
    {{- toYaml .Values.podLabels | nindent 4 }}
  type: {{ .Values.service.type }}
  ports:
  - name: {{ .Values.service.port.name }}
    port: {{ .Values.service.port.port }}
    protocol: {{ .Values.service.port.protocol }}
    nodePort: {{ .Values.service.port.nodePort }}
```

values.yaml

```yaml
deployment:
  name: multitool

replicaCount: 1

image:
  name: multitool
  repository: wbitt/network-multitool

deploymentLabels: 
  app: multitool
podLabels: 
  app: multitool

service:
  name: multitool
  type: NodePort
  port:
    name: web
    port: 80
    protocol: TCP
    nodePort: 30080
```

Установка и обновление

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-10/netology-chart$ helm install netology .

NAME: netology
LAST DEPLOYED: Wed Jul 16 23:17:01 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None


sergey@netology-01:~/Work/netology-devops/k8s/k8s-10/netology-chart$ helm upgrade netology .

Release "netology" has been upgraded. Happy Helming!
NAME: netology
LAST DEPLOYED: Wed Jul 16 23:17:22 2025
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
```

### Задание 2. Запустить две версии в разных неймспейсах

alpine

```yaml
deployment:
  name: multitool-wbitt

service:
  name: multitool-wbitt

deploymentLabels: 
  app: multitool-wbitt
podLabels: 
  app: multitool-wbitt

image:
  repository: wbitt/network-multitool:alpine-minimal
```

praqma

```yaml
deployment:
  name: multitool-praqma

service:
  name: multitool-praqma

deploymentLabels: 
  app: multitool-praqma
podLabels: 
  app: multitool-praqma

image:
  repository: praqma/network-multitool
```

wbitt

```yaml
deployment:
  name: multitool-wbitt

service:
  name: multitool-wbitt

deploymentLabels: 
  app: multitool-wbitt
podLabels: 
  app: multitool-wbitt

image:
  repository: wbitt/network-multitool
```

установка

```
sergey@netology-01:~/Work/netology-devops/k8s/k8s-10/netology-chart$ helm install multitool-wbitt . -n app1 -f wbitt.yaml --set service.port.nodePort=30081

NAME: multitool-wbitt
LAST DEPLOYED: Wed Jul 16 23:24:09 2025
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None


sergey@netology-01:~/Work/netology-devops/k8s/k8s-10/netology-chart$ helm install multitool-praqma . -n app1 -f praqma.yaml --set service.port.nodePort=30080

NAME: multitool-praqma
LAST DEPLOYED: Wed Jul 16 23:27:16 2025
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None


sergey@netology-01:~/Work/netology-devops/k8s/k8s-10/netology-chart$ helm install multitool-wbitt . -n app2 -f alpine.yaml --set service.port.nodePort=30082

NAME: multitool-wbitt
LAST DEPLOYED: Wed Jul 16 23:28:00 2025
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
```