# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

### Решение

При помощи terraform создаем сервисный аккаунт и бакет, сохраняем ключи для следующего шага. [Конфигурация](./bucket/).

<p><details><summary>$ terraform apply</summary>

<pre>
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.credfile will be created
  + resource "local_file" "credfile" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../kuber/credfile.key"
      + id                   = (known after apply)
    }

  # yandex_iam_service_account.sa-diplom will be created
  + resource "yandex_iam_service_account" "sa-diplom" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + name       = "sa-diplom"
    }

  # yandex_iam_service_account_static_access_key.sa-static-key will be created
  + resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
      + access_key                   = (known after apply)
      + created_at                   = (known after apply)
      + description                  = "static access key"
      + encrypted_secret_key         = (known after apply)
      + id                           = (known after apply)
      + key_fingerprint              = (known after apply)
      + output_to_lockbox_version_id = (known after apply)
      + secret_key                   = (sensitive value)
      + service_account_id           = (known after apply)
    }

  # yandex_resourcemanager_folder_iam_member.diplom-editor will be created
  + resource "yandex_resourcemanager_folder_iam_member" "diplom-editor" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "editor"
    }

  # yandex_storage_bucket.slagovskiy-bucket will be created
  + resource "yandex_storage_bucket" "slagovskiy-bucket" {
      + access_key            = (known after apply)
      + acl                   = (known after apply)
      + bucket                = "slagovskiy-bucket"
      + bucket_domain_name    = (known after apply)
      + default_storage_class = (known after apply)
      + folder_id             = (known after apply)
      + force_destroy         = true
      + id                    = (known after apply)
      + max_size              = 1073741824
      + policy                = (known after apply)
      + secret_key            = (sensitive value)
      + website_domain        = (known after apply)
      + website_endpoint      = (known after apply)

      + anonymous_access_flags {
          + config_read = false
          + list        = false
          + read        = false
        }

      + grant (known after apply)

      + versioning (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_iam_service_account.sa-diplom: Creating...
yandex_iam_service_account.sa-diplom: Creation complete after 2s [id=ajeoqhl6afect60ikefq]
yandex_resourcemanager_folder_iam_member.diplom-editor: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creation complete after 1s [id=ajemp5o43n9mk807qpp5]
local_file.credfile: Creating...
local_file.credfile: Creation complete after 0s [id=b7dad83e922223b9a6553106c2094755e42c52d0]
yandex_resourcemanager_folder_iam_member.diplom-editor: Creation complete after 2s [id=b1gghlg0i9r4su8up17l/editor/serviceAccount:ajeoqhl6afect60ikefq]
yandex_storage_bucket.slagovskiy-bucket: Creating...
yandex_storage_bucket.slagovskiy-bucket: Creation complete after 5s [id=slagovskiy-bucket]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

</pre>
</details></p>

Проверяем созаднное.

Сервисный аккаунт.

```
$ yc iam service-account list

+----------------------+-----------+--------+---------------------+-----------------------+
|          ID          |   NAME    | LABELS |     CREATED AT      | LAST AUTHENTICATED AT |
+----------------------+-----------+--------+---------------------+-----------------------+
| ajeksvicm9mgluiniav6 | terra     |        | 2025-02-05 13:30:57 | 2025-02-05 17:10:00   |
| ajeoqhl6afect60ikefq | sa-diplom |        | 2025-08-16 18:38:25 | 2025-08-16 18:30:00   |
+----------------------+-----------+--------+---------------------+-----------------------+


$ yc iam service-account get sa-diplom

id: ajeoqhl6afect60ikefq
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-08-16T18:38:25Z"
name: sa-diplom
last_authenticated_at: "2025-08-16T18:30:00Z"

```

Бакет

```
$ yc storage bucket list

+-------------------+----------------------+------------+-----------------------+---------------------+
|       NAME        |      FOLDER ID       |  MAX SIZE  | DEFAULT STORAGE CLASS |     CREATED AT      |
+-------------------+----------------------+------------+-----------------------+---------------------+
| slagovskiy-bucket | b1gghlg0i9r4su8up17l | 1073741824 | STANDARD              | 2025-08-16 18:38:30 |
+-------------------+----------------------+------------+-----------------------+---------------------+


$ yc storage bucket get slagovskiy-bucket

name: slagovskiy-bucket
folder_id: b1gghlg0i9r4su8up17l
anonymous_access_flags:
  read: false
  list: false
  config_read: false
default_storage_class: STANDARD
versioning: VERSIONING_DISABLED
max_size: "1073741824"
created_at: "2025-08-16T18:38:30.680493Z"
resource_id: e3e1q439eh6kppg44csq

```

Ключи для дальнейшей работы

```
$ ls ../kuber/cred*

../kuber/credfile.key
```

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

### Решение

Воспользуемся развертыванием через Yandex Managment Service for Kubernetes.

Поднимаем 3 сети, сервисный аккаунт для кластера, кластер в 3х зонах доступности, 3 группы ВМ по 1 ВМ в каждой зоне.
[Конфигурация](./terraform/).

<p><details><summary>$ terraform apply</summary>

<pre>
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_iam_service_account.my-regional-account will be created
  + resource "yandex_iam_service_account" "my-regional-account" {
      + created_at  = (known after apply)
      + description = "K8S regional service account"
      + folder_id   = (known after apply)
      + id          = (known after apply)
      + name        = "regional-k8s-account"
    }

  # yandex_kms_symmetric_key.kms-key will be created
  + resource "yandex_kms_symmetric_key" "kms-key" {
      + created_at          = (known after apply)
      + default_algorithm   = "AES_128"
      + deletion_protection = false
      + folder_id           = (known after apply)
      + id                  = (known after apply)
      + name                = "kms-key"
      + rotated_at          = (known after apply)
      + rotation_period     = "8760h"
      + status              = (known after apply)
    }

  # yandex_kubernetes_cluster.k8s-regional will be created
  + resource "yandex_kubernetes_cluster" "k8s-regional" {
      + cluster_ipv4_range       = (known after apply)
      + cluster_ipv6_range       = (known after apply)
      + created_at               = (known after apply)
      + description              = (known after apply)
      + folder_id                = (known after apply)
      + health                   = (known after apply)
      + id                       = (known after apply)
      + labels                   = (known after apply)
      + log_group_id             = (known after apply)
      + name                     = "k8s-regional"
      + network_id               = (known after apply)
      + node_ipv4_cidr_mask_size = 24
      + node_service_account_id  = (known after apply)
      + release_channel          = (known after apply)
      + service_account_id       = (known after apply)
      + service_ipv4_range       = (known after apply)
      + service_ipv6_range       = (known after apply)
      + status                   = (known after apply)

      + kms_provider {
          + key_id = (known after apply)
        }

      + master {
          + cluster_ca_certificate = (known after apply)
          + etcd_cluster_size      = (known after apply)
          + external_v4_address    = (known after apply)
          + external_v4_endpoint   = (known after apply)
          + external_v6_endpoint   = (known after apply)
          + internal_v4_address    = (known after apply)
          + internal_v4_endpoint   = (known after apply)
          + public_ip              = true
          + security_group_ids     = (known after apply)
          + version                = (known after apply)
          + version_info           = (known after apply)

          + maintenance_policy (known after apply)

          + master_location {
              + subnet_id = (known after apply)
              + zone      = "ru-central1-a"
            }
          + master_location {
              + subnet_id = (known after apply)
              + zone      = "ru-central1-b"
            }
          + master_location {
              + subnet_id = (known after apply)
              + zone      = "ru-central1-d"
            }

          + regional (known after apply)

          + scale_policy (known after apply)

          + zonal (known after apply)
        }
    }

  # yandex_kubernetes_node_group.node-group[0] will be created
  + resource "yandex_kubernetes_node_group" "node-group" {
      + cluster_id        = (known after apply)
      + created_at        = (known after apply)
      + description       = "First node group"
      + id                = (known after apply)
      + instance_group_id = (known after apply)
      + labels            = {
          + "key" = "value"
        }
      + name              = "node-group-0"
      + status            = (known after apply)
      + version           = (known after apply)
      + version_info      = (known after apply)

      + allocation_policy {
          + location {
              + subnet_id = (known after apply)
              + zone      = "ru-central1-a"
            }
        }

      + deploy_policy (known after apply)

      + instance_template {
          + metadata                  = (known after apply)
          + nat                       = (known after apply)
          + network_acceleration_type = (known after apply)
          + platform_id               = "standard-v2"

          + boot_disk {
              + size = 50
              + type = "network-ssd"
            }

          + container_network (known after apply)

          + container_runtime {
              + type = "containerd"
            }

          + gpu_settings (known after apply)

          + network_interface {
              + ipv4       = true
              + ipv6       = (known after apply)
              + nat        = true
              + subnet_ids = (known after apply)
            }

          + resources {
              + core_fraction = 20
              + cores         = 2
              + gpus          = 0
              + memory        = 2
            }

          + scheduling_policy {
              + preemptible = true
            }
        }

      + maintenance_policy {
          + auto_repair  = true
          + auto_upgrade = true
        }

      + scale_policy {
          + fixed_scale {
              + size = 1
            }
        }
    }

  # yandex_kubernetes_node_group.node-group[1] will be created
  + resource "yandex_kubernetes_node_group" "node-group" {
      + cluster_id        = (known after apply)
      + created_at        = (known after apply)
      + description       = "First node group"
      + id                = (known after apply)
      + instance_group_id = (known after apply)
      + labels            = {
          + "key" = "value"
        }
      + name              = "node-group-1"
      + status            = (known after apply)
      + version           = (known after apply)
      + version_info      = (known after apply)

      + allocation_policy {
          + location {
              + subnet_id = (known after apply)
              + zone      = "ru-central1-b"
            }
        }

      + deploy_policy (known after apply)

      + instance_template {
          + metadata                  = (known after apply)
          + nat                       = (known after apply)
          + network_acceleration_type = (known after apply)
          + platform_id               = "standard-v2"

          + boot_disk {
              + size = 50
              + type = "network-ssd"
            }

          + container_network (known after apply)

          + container_runtime {
              + type = "containerd"
            }

          + gpu_settings (known after apply)

          + network_interface {
              + ipv4       = true
              + ipv6       = (known after apply)
              + nat        = true
              + subnet_ids = (known after apply)
            }

          + resources {
              + core_fraction = 20
              + cores         = 2
              + gpus          = 0
              + memory        = 2
            }

          + scheduling_policy {
              + preemptible = true
            }
        }

      + maintenance_policy {
          + auto_repair  = true
          + auto_upgrade = true
        }

      + scale_policy {
          + fixed_scale {
              + size = 1
            }
        }
    }

  # yandex_kubernetes_node_group.node-group[2] will be created
  + resource "yandex_kubernetes_node_group" "node-group" {
      + cluster_id        = (known after apply)
      + created_at        = (known after apply)
      + description       = "First node group"
      + id                = (known after apply)
      + instance_group_id = (known after apply)
      + labels            = {
          + "key" = "value"
        }
      + name              = "node-group-2"
      + status            = (known after apply)
      + version           = (known after apply)
      + version_info      = (known after apply)

      + allocation_policy {
          + location {
              + subnet_id = (known after apply)
              + zone      = "ru-central1-d"
            }
        }

      + deploy_policy (known after apply)

      + instance_template {
          + metadata                  = (known after apply)
          + nat                       = (known after apply)
          + network_acceleration_type = (known after apply)
          + platform_id               = "standard-v2"

          + boot_disk {
              + size = 50
              + type = "network-ssd"
            }

          + container_network (known after apply)

          + container_runtime {
              + type = "containerd"
            }

          + gpu_settings (known after apply)

          + network_interface {
              + ipv4       = true
              + ipv6       = (known after apply)
              + nat        = true
              + subnet_ids = (known after apply)
            }

          + resources {
              + core_fraction = 20
              + cores         = 2
              + gpus          = 0
              + memory        = 2
            }

          + scheduling_policy {
              + preemptible = true
            }
        }

      + maintenance_policy {
          + auto_repair  = true
          + auto_upgrade = true
        }

      + scale_policy {
          + fixed_scale {
              + size = 1
            }
        }
    }

  # yandex_resourcemanager_folder_iam_member.k8s-roles["container-registry.images.puller"] will be created
  + resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "container-registry.images.puller"
    }

  # yandex_resourcemanager_folder_iam_member.k8s-roles["dns.editor"] will be created
  + resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "dns.editor"
    }

  # yandex_resourcemanager_folder_iam_member.k8s-roles["k8s.clusters.agent"] will be created
  + resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "k8s.clusters.agent"
    }

  # yandex_resourcemanager_folder_iam_member.k8s-roles["kms.keys.encrypterDecrypter"] will be created
  + resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "kms.keys.encrypterDecrypter"
    }

  # yandex_resourcemanager_folder_iam_member.k8s-roles["load-balancer.admin"] will be created
  + resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "load-balancer.admin"
    }

  # yandex_resourcemanager_folder_iam_member.k8s-roles["vpc.publicAdmin"] will be created
  + resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
      + folder_id = "b1gghlg0i9r4su8up17l"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "vpc.publicAdmin"
    }

  # yandex_vpc_network.app-net will be created
  + resource "yandex_vpc_network" "app-net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "app-net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_security_group.regional-k8s-sg will be created
  + resource "yandex_vpc_security_group" "regional-k8s-sg" {
      + created_at  = (known after apply)
      + description = "Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Примените ее к кластеру и группам узлов."
      + folder_id   = (known after apply)
      + id          = (known after apply)
      + labels      = (known after apply)
      + name        = "regional-k8s-sg"
      + network_id  = (known after apply)
      + status      = (known after apply)

      + egress {
          + description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
          + from_port         = 0
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = -1
          + protocol          = "ANY"
          + to_port           = 65535
          + v4_cidr_blocks    = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks    = []
            # (2 unchanged attributes hidden)
        }

      + ingress {
          + description       = "Allow access to Kubernetes API via port 443 from internet."
          + from_port         = -1
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = 443
          + protocol          = "TCP"
          + to_port           = -1
          + v4_cidr_blocks    = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks    = []
            # (2 unchanged attributes hidden)
        }
      + ingress {
          + description       = "Allow access to Kubernetes API via port 6443 from internet."
          + from_port         = -1
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = 6443
          + protocol          = "TCP"
          + to_port           = -1
          + v4_cidr_blocks    = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks    = []
            # (2 unchanged attributes hidden)
        }
      + ingress {
          + description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
          + from_port         = 0
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = -1
          + predefined_target = "self_security_group"
          + protocol          = "ANY"
          + to_port           = 65535
          + v4_cidr_blocks    = []
          + v6_cidr_blocks    = []
            # (1 unchanged attribute hidden)
        }
      + ingress {
          + description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
          + from_port         = 0
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = -1
          + protocol          = "ANY"
          + to_port           = 65535
          + v4_cidr_blocks    = [
              + "10.10.1.0/24",
              + "10.10.2.0/24",
              + "10.10.3.0/24",
            ]
          + v6_cidr_blocks    = []
            # (2 unchanged attributes hidden)
        }
      + ingress {
          + description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
          + from_port         = 30000
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = -1
          + protocol          = "TCP"
          + to_port           = 32767
          + v4_cidr_blocks    = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks    = []
            # (2 unchanged attributes hidden)
        }
      + ingress {
          + description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
          + from_port         = -1
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = -1
          + protocol          = "ICMP"
          + to_port           = -1
          + v4_cidr_blocks    = [
              + "10.0.0.0/8",
              + "172.16.0.0/12",
              + "192.168.0.0/16",
            ]
          + v6_cidr_blocks    = []
            # (2 unchanged attributes hidden)
        }
      + ingress {
          + description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
          + from_port         = 0
          + id                = (known after apply)
          + labels            = (known after apply)
          + port              = -1
          + predefined_target = "loadbalancer_healthchecks"
          + protocol          = "TCP"
          + to_port           = 65535
          + v4_cidr_blocks    = []
          + v6_cidr_blocks    = []
            # (1 unchanged attribute hidden)
        }
    }

  # yandex_vpc_subnet.app-subnet-zones[0] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.app-subnet-zones[1] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.app-subnet-zones[2] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-d"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-d"
    }

Plan: 17 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cluster_id           = (known after apply)
  + cluster_name         = "k8s-regional"
  + external_cluster_cmd = (known after apply)
  + external_v4_address  = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_kms_symmetric_key.kms-key: Creating...
yandex_vpc_network.app-net: Creating...
yandex_iam_service_account.my-regional-account: Creating...
yandex_kms_symmetric_key.kms-key: Creation complete after 1s [id=abjkckhvnpa24pb78te6]
yandex_iam_service_account.my-regional-account: Creation complete after 2s [id=ajefgkprfkgqkii29cir]
yandex_resourcemanager_folder_iam_member.k8s-roles["dns.editor"]: Creating...
yandex_resourcemanager_folder_iam_member.k8s-roles["load-balancer.admin"]: Creating...
yandex_resourcemanager_folder_iam_member.k8s-roles["vpc.publicAdmin"]: Creating...
yandex_resourcemanager_folder_iam_member.k8s-roles["kms.keys.encrypterDecrypter"]: Creating...
yandex_resourcemanager_folder_iam_member.k8s-roles["k8s.clusters.agent"]: Creating...
yandex_resourcemanager_folder_iam_member.k8s-roles["container-registry.images.puller"]: Creating...
yandex_vpc_network.app-net: Creation complete after 3s [id=enp289l24mga85uc9i2j]
yandex_vpc_subnet.app-subnet-zones[1]: Creating...
yandex_vpc_subnet.app-subnet-zones[2]: Creating...
yandex_vpc_subnet.app-subnet-zones[0]: Creating...
yandex_vpc_subnet.app-subnet-zones[0]: Creation complete after 1s [id=e9bed1ua8tlsh9cskp1l]
yandex_vpc_subnet.app-subnet-zones[2]: Creation complete after 1s [id=fl8s69l12rcatfdleq2k]
yandex_vpc_subnet.app-subnet-zones[1]: Creation complete after 2s [id=e2lp4lracshrsmta63j4]
yandex_vpc_security_group.regional-k8s-sg: Creating...
yandex_resourcemanager_folder_iam_member.k8s-roles["dns.editor"]: Creation complete after 3s [id=b1gghlg0i9r4su8up17l/dns.editor/serviceAccount:ajefgkprfkgqkii29cir]
yandex_resourcemanager_folder_iam_member.k8s-roles["vpc.publicAdmin"]: Creation complete after 6s [id=b1gghlg0i9r4su8up17l/vpc.publicAdmin/serviceAccount:ajefgkprfkgqkii29cir]
yandex_vpc_security_group.regional-k8s-sg: Creation complete after 3s [id=enpfr8hh7evup80huc2d]
yandex_resourcemanager_folder_iam_member.k8s-roles["load-balancer.admin"]: Creation complete after 8s [id=b1gghlg0i9r4su8up17l/load-balancer.admin/serviceAccount:ajefgkprfkgqkii29cir]
yandex_resourcemanager_folder_iam_member.k8s-roles["kms.keys.encrypterDecrypter"]: Still creating... [10s elapsed]
yandex_resourcemanager_folder_iam_member.k8s-roles["k8s.clusters.agent"]: Still creating... [10s elapsed]
yandex_resourcemanager_folder_iam_member.k8s-roles["container-registry.images.puller"]: Still creating... [10s elapsed]
yandex_resourcemanager_folder_iam_member.k8s-roles["kms.keys.encrypterDecrypter"]: Creation complete after 11s [id=b1gghlg0i9r4su8up17l/kms.keys.encrypterDecrypter/serviceAccount:ajefgkprfkgqkii29cir]
yandex_resourcemanager_folder_iam_member.k8s-roles["container-registry.images.puller"]: Creation complete after 14s [id=b1gghlg0i9r4su8up17l/container-registry.images.puller/serviceAccount:ajefgkprfkgqkii29cir]
yandex_resourcemanager_folder_iam_member.k8s-roles["k8s.clusters.agent"]: Creation complete after 16s [id=b1gghlg0i9r4su8up17l/k8s.clusters.agent/serviceAccount:ajefgkprfkgqkii29cir]
yandex_kubernetes_cluster.k8s-regional: Creating...
yandex_kubernetes_cluster.k8s-regional: Still creating... [10s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [20s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [30s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [40s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [50s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [1m0s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [1m10s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [1m20s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [1m30s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [1m40s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [1m50s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [2m0s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [2m10s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [2m20s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [2m30s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [2m40s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [2m50s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [3m0s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [3m10s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [3m20s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [3m30s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [3m40s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [3m50s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [4m0s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [4m10s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [4m20s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [4m30s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [4m40s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [4m50s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [5m0s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [5m10s elapsed]
yandex_kubernetes_cluster.k8s-regional: Still creating... [5m20s elapsed]
yandex_kubernetes_cluster.k8s-regional: Creation complete after 5m29s [id=catqjjk9ql50jp2qep42]
yandex_kubernetes_node_group.node-group[2]: Creating...
yandex_kubernetes_node_group.node-group[0]: Creating...
yandex_kubernetes_node_group.node-group[1]: Creating...
yandex_kubernetes_node_group.node-group[2]: Still creating... [10s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [10s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [10s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [20s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [20s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [20s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [30s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [30s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [30s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [40s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [40s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [40s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [50s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [50s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [50s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [1m0s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [1m0s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [1m0s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [1m10s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [1m10s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [1m10s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [1m20s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [1m20s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [1m20s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [1m30s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [1m30s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [1m30s elapsed]
yandex_kubernetes_node_group.node-group[2]: Still creating... [1m40s elapsed]
yandex_kubernetes_node_group.node-group[0]: Still creating... [1m40s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [1m40s elapsed]
yandex_kubernetes_node_group.node-group[2]: Creation complete after 1m40s [id=catssvkgr8frt8bqvnr9]
yandex_kubernetes_node_group.node-group[0]: Still creating... [1m50s elapsed]
yandex_kubernetes_node_group.node-group[1]: Still creating... [1m50s elapsed]
yandex_kubernetes_node_group.node-group[0]: Creation complete after 1m50s [id=catdpgk01dl3curqfg0h]
yandex_kubernetes_node_group.node-group[1]: Creation complete after 1m58s [id=catnu315gvj0lril5hq6]

Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

cluster_id = "catqjjk9ql50jp2qep42"
cluster_name = "k8s-regional"
external_cluster_cmd = "yc managed-kubernetes cluster get-credentials --id catqjjk9ql50jp2qep42 --external"
external_v4_address = "158.160.191.253"
</pre>
</details></p>


Смотрим что получилось.

VMs

```
$ yc compute instances list

+----------------------+---------------------------+---------------+---------+-----------------+-------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  |   EXTERNAL IP   | INTERNAL IP |
+----------------------+---------------------------+---------------+---------+-----------------+-------------+
| epdvf88ct5gevciu4nmq | cl1f0kj5k346vbn1k608-ehij | ru-central1-b | RUNNING | 51.250.108.124  | 10.10.2.12  |
| fhmcb8j5ofmksfgui92i | cl1mqe09dmbd92dvp4h5-uwuh | ru-central1-a | RUNNING | 84.201.128.137  | 10.10.1.17  |
| fv4ndel180bfavjn8a75 | cl1mg3vtj45mpeg7292j-evak | ru-central1-d | RUNNING | 158.160.192.157 | 10.10.3.21  |
+----------------------+---------------------------+---------------+---------+-----------------+-------------+
```

Networks

```
$ yc vpc network list

+----------------------+---------+
|          ID          |  NAME   |
+----------------------+---------+
| enp289l24mga85uc9i2j | app-net |
+----------------------+---------+
```

subnets

```
$ yc vpc subnet list

+----------------------+-----------------------------------------------------------+----------------------+----------------+---------------+-----------------+
|          ID          |                           NAME                            |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
+----------------------+-----------------------------------------------------------+----------------------+----------------+---------------+-----------------+
| e2lp4lracshrsmta63j4 | subnet-ru-central1-b                                      | enp289l24mga85uc9i2j |                | ru-central1-b | [10.10.2.0/24]  |
| e9b7puc15obu4bisrpls | k8s-cluster-catqjjk9ql50jp2qep42-service-cidr-reservation | enp289l24mga85uc9i2j |                | ru-central1-a | [10.96.0.0/16]  |
| e9bd898n69numf6l4c6j | k8s-cluster-catqjjk9ql50jp2qep42-pod-cidr-reservation     | enp289l24mga85uc9i2j |                | ru-central1-a | [10.112.0.0/16] |
| e9bed1ua8tlsh9cskp1l | subnet-ru-central1-a                                      | enp289l24mga85uc9i2j |                | ru-central1-a | [10.10.1.0/24]  |
| fl8s69l12rcatfdleq2k | subnet-ru-central1-d                                      | enp289l24mga85uc9i2j |                | ru-central1-d | [10.10.3.0/24]  |
+----------------------+-----------------------------------------------------------+----------------------+----------------+---------------+-----------------+
```

security groups

```
$ yc vpc security-group list

+----------------------+---------------------------------+--------------------------------+----------------------+
|          ID          |              NAME               |          DESCRIPTION           |      NETWORK-ID      |
+----------------------+---------------------------------+--------------------------------+----------------------+
| enpfr8hh7evup80huc2d | regional-k8s-sg                 | Правила группы обеспечивают    | enp289l24mga85uc9i2j |
|                      |                                 | базовую работоспособность      |                      |
|                      |                                 | кластера Managed Service for   |                      |
|                      |                                 | Kubernetes. Примените ее к     |                      |
|                      |                                 | кластеру и группам узлов.      |                      |
| enphsq074sf48tm9apem | default-sg-enp289l24mga85uc9i2j | Default security group for     | enp289l24mga85uc9i2j |
|                      |                                 | network                        |                      |
+----------------------+---------------------------------+--------------------------------+----------------------+
```

<p><details><summary>security group rules detail</summary>

<pre>
$ yc vpc security-group get regional-k8s-sg
id: enpfr8hh7evup80huc2d
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-08-16T19:02:31Z"
name: regional-k8s-sg
description: Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Примените ее к кластеру и группам узлов.
network_id: enp289l24mga85uc9i2j
status: ACTIVE
rules:
  - id: enp4jlknbs3e12t0ql4u
    description: Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д.
    direction: EGRESS
    ports:
      to_port: "65535"
    protocol_name: ANY
    protocol_number: "-1"
    cidr_blocks:
      v4_cidr_blocks:
        - 0.0.0.0/0
  - id: enpli0jq3c4tjpredl64
    description: Allow access to Kubernetes API via port 443 from internet.
    direction: INGRESS
    ports:
      from_port: "443"
      to_port: "443"
    protocol_name: TCP
    protocol_number: "6"
    cidr_blocks:
      v4_cidr_blocks:
        - 0.0.0.0/0
  - id: enp9thos2ll3pu34aob9
    description: Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика.
    direction: INGRESS
    ports:
      to_port: "65535"
    protocol_name: TCP
    protocol_number: "6"
    predefined_target: loadbalancer_healthchecks
  - id: enpsb2r0d6bq2gtg9jcg
    description: Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам.
    direction: INGRESS
    ports:
      from_port: "30000"
      to_port: "32767"
    protocol_name: TCP
    protocol_number: "6"
    cidr_blocks:
      v4_cidr_blocks:
        - 0.0.0.0/0
  - id: enpm39uune03popsvs9n
    description: Allow access to Kubernetes API via port 6443 from internet.
    direction: INGRESS
    ports:
      from_port: "6443"
      to_port: "6443"
    protocol_name: TCP
    protocol_number: "6"
    cidr_blocks:
      v4_cidr_blocks:
        - 0.0.0.0/0
  - id: enp7d9d7jtgvnr2vhoaj
    description: Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов.
    direction: INGRESS
    ports:
      to_port: "65535"
    protocol_name: ANY
    protocol_number: "-1"
    cidr_blocks:
      v4_cidr_blocks:
        - 10.10.1.0/24
        - 10.10.2.0/24
        - 10.10.3.0/24
  - id: enpf0pult9dd0pdv02sj
    description: Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности.
    direction: INGRESS
    ports:
      to_port: "65535"
    protocol_name: ANY
    protocol_number: "-1"
    predefined_target: self_security_group
  - id: enpjm83rlh5b6d68rpqc
    description: Правило разрешает отладочные ICMP-пакеты из внутренних подсетей.
    direction: INGRESS
    protocol_name: ICMP
    protocol_number: "1"
    cidr_blocks:
      v4_cidr_blocks:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16
</pre>
</details></p>

service account for k8s

```
$ yc iam service-account list

+----------------------+----------------------+--------+---------------------+-----------------------+
|          ID          |         NAME         | LABELS |     CREATED AT      | LAST AUTHENTICATED AT |
+----------------------+----------------------+--------+---------------------+-----------------------+
| ajefgkprfkgqkii29cir | regional-k8s-account |        | 2025-08-16 19:02:24 | 2025-08-16 19:10:00   |
| ajeksvicm9mgluiniav6 | terra                |        | 2025-02-05 13:30:57 | 2025-02-05 17:10:00   |
| ajeoqhl6afect60ikefq | sa-diplom            |        | 2025-08-16 18:38:25 | 2025-08-16 18:30:00   |
+----------------------+----------------------+--------+---------------------+-----------------------+


$ yc iam service-account get regional-k8s-account

id: ajefgkprfkgqkii29cir
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-08-16T19:02:24Z"
name: regional-k8s-account
description: K8S regional service account
last_authenticated_at: "2025-08-16T19:10:00Z"
```

k8s cluster

```
$ yc managed-kubernetes cluster list

+----------------------+--------------+---------------------+---------+---------+-------------------------+--------------------+
|          ID          |     NAME     |     CREATED AT      | HEALTH  | STATUS  |    EXTERNAL ENDPOINT    | INTERNAL ENDPOINT  |
+----------------------+--------------+---------------------+---------+---------+-------------------------+--------------------+
| catqjjk9ql50jp2qep42 | k8s-regional | 2025-08-16 19:02:42 | HEALTHY | RUNNING | https://158.160.191.253 | https://10.10.1.21 |
+----------------------+--------------+---------------------+---------+---------+-------------------------+--------------------+
```

<p><details><summary>cluster details</summary>

<pre>
$ yc managed-kubernetes cluster get k8s-regional
id: catqjjk9ql50jp2qep42
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-08-16T19:02:42Z"
name: k8s-regional
status: RUNNING
health: HEALTHY
network_id: enp289l24mga85uc9i2j
master:
  regional_master:
    region_id: ru-central1
    internal_v4_address: 10.10.1.21
    external_v4_address: 158.160.191.253
  locations:
    - zone_id: ru-central1-a
      subnet_id: e9bed1ua8tlsh9cskp1l
    - zone_id: ru-central1-b
      subnet_id: e2lp4lracshrsmta63j4
    - zone_id: ru-central1-d
      subnet_id: fl8s69l12rcatfdleq2k
  etcd_cluster_size: "3"
  version: "1.32"
  endpoints:
    internal_v4_endpoint: https://10.10.1.21
    external_v4_endpoint: https://158.160.191.253
  master_auth:
    cluster_ca_certificate: |
      -----BEGIN CERTIFICATE-----
      MIIC5zCCAc+gAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
      cm5ldGVzMB4XDTI1MDgxNjE5MDI0NFoXDTM1MDgxNDE5MDI0NFowFTETMBEGA1UE
      AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPSP
      9bK1ntlERHbiVpunkB/w/gFuS5i1UZ3vHbc4JUsWi4vVs6yP7D69tzMzG8RLMyco
      Be4PTBCe5SAMxquQJuhv8lHaJ0b3mQj6VTXh8Cn9XFgxJ7P+/hWieb4LOw0pF0d1
      tvSji2fk9mYBWUinf4EJZOypwt1u0cmvoH4aNbPTNEURX2saOjsg5Rwve6RP7Leo
      7RWouEb2zW8aSL9ch/RNUg3Cz3icNAKff2Lcqm54wcb9tYR5M9cTiAJ9gidYk/Ef
      rlC80GflLXrND6Et0Rl144EPVGobojhPOVkwW3P2uI7mX6W/ykBSyeLQq6fY5FsT
      26ksTR4oUrQsdOa+XdkCAwEAAaNCMEAwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
      /wQFMAMBAf8wHQYDVR0OBBYEFGVSB1VGrC+UjbDB8SOpZJ/myBKZMA0GCSqGSIb3
      DQEBCwUAA4IBAQCAszcCtK+W9UByYpQ4T7Wcf/hf5vPcgki05W5kXEOugJo9KDKk
      00gia7s/ZOWAxbM6YCduY/xIvBorhXsHKgwMsvNYVx4A427UTYhiITmZyjqyonWy
      ng7VZFAoNHUtZYW8j9hKp10t7BGo1csGp9dKUuumT6SsYUec04GH0BQzBGCkZ2yu
      5Om+PGXO5uzfPjculxxt37zlL4l1q9+7NdnLPrTyTbx9slTpVToaNMLyZiKxn/+S
      qbp6tzTbFd/9bDkyg9RHaApPh5/ZHfLpVtGQfIJjjPQTGJlqFc+0btuTdZFfmcdn
      Aj9jXwcy84q4ofVGdjnrNSPNWHQ25ddE0nu5
      -----END CERTIFICATE-----
  version_info:
    current_version: "1.32"
  maintenance_policy:
    auto_upgrade: true
    maintenance_window:
      anytime: {}
  security_group_ids:
    - enpfr8hh7evup80huc2d
  resources:
    cores: "2"
    core_fraction: "100"
    memory: "8589934592"
  scale_policy:
    auto_scale:
      min_resource_preset_id: s-c2-m8
ip_allocation_policy:
  cluster_ipv4_cidr_block: 10.112.0.0/16
  node_ipv4_cidr_mask_size: "24"
  service_ipv4_cidr_block: 10.96.0.0/16
service_account_id: ajefgkprfkgqkii29cir
node_service_account_id: ajefgkprfkgqkii29cir
release_channel: REGULAR
kms_provider:
  key_id: abjkckhvnpa24pb78te6
</pre>
</details></p>

cluster nodes

```
$ yc managed-kubernetes cluster list-nodes k8s-regional

+--------------------------------+---------------------------+--------------------------------+-------------+--------+
|         CLOUD INSTANCE         |      KUBERNETES NODE      |           RESOURCES            |    DISK     | STATUS |
+--------------------------------+---------------------------+--------------------------------+-------------+--------+
| epdvf88ct5gevciu4nmq           | cl1f0kj5k346vbn1k608-ehij | 2 20% core(s), 2.0 GB of       | 50.0 GB ssd | READY  |
| RUNNING_ACTUAL                 |                           | memory                         |             |        |
| fv4ndel180bfavjn8a75           | cl1mg3vtj45mpeg7292j-evak | 2 20% core(s), 2.0 GB of       | 50.0 GB ssd | READY  |
| RUNNING_ACTUAL                 |                           | memory                         |             |        |
| fhmcb8j5ofmksfgui92i           | cl1mqe09dmbd92dvp4h5-uwuh | 2 20% core(s), 2.0 GB of       | 50.0 GB ssd | READY  |
| RUNNING_ACTUAL                 |                           | memory                         |             |        |
+--------------------------------+---------------------------+--------------------------------+-------------+--------+
```

cluster node groups

```
$ yc managed-kubernetes cluster list-node-groups k8s-regional

+----------------------+--------------+----------------------+---------------------+---------+------+
|          ID          |     NAME     |  INSTANCE GROUP ID   |     CREATED AT      | STATUS  | SIZE |
+----------------------+--------------+----------------------+---------------------+---------+------+
| catdpgk01dl3curqfg0h | node-group-0 | cl1mqe09dmbd92dvp4h5 | 2025-08-16 19:08:10 | RUNNING |    1 |
| catnu315gvj0lril5hq6 | node-group-1 | cl1f0kj5k346vbn1k608 | 2025-08-16 19:08:10 | RUNNING |    1 |
| catssvkgr8frt8bqvnr9 | node-group-2 | cl1mg3vtj45mpeg7292j | 2025-08-16 19:08:10 | RUNNING |    1 |
+----------------------+--------------+----------------------+---------------------+---------+------+
```

Получили 3 ноды в разных зонах доступности.

Подключимся к кластеру и получим с него базовую информацию.

Для добавления конфигурации кластера в конфигурационный файл нужно выполнить команду `yc managed-kubernetes cluster get-credentials --id catqjjk9ql50jp2qep42 --external`.

```
$ yc managed-kubernetes cluster get-credentials --id catqjjk9ql50jp2qep42 --external

Context 'yc-k8s-regional' was added as default to kubeconfig '/home/sergey/.kube/config'.
Check connection to cluster using 'kubectl cluster-info --kubeconfig /home/sergey/.kube/config'.

Note, that authentication depends on 'yc' and its config profile 'default'.
To access clusters using the Kubernetes API, please use Kubernetes Service Account.
```

Посмотрим состав кластера

```
$ kubectl get nodes

NAME                        STATUS   ROLES    AGE   VERSION
cl1f0kj5k346vbn1k608-ehij   Ready    <none>   40m   v1.32.1
cl1mg3vtj45mpeg7292j-evak   Ready    <none>   40m   v1.32.1
cl1mqe09dmbd92dvp4h5-uwuh   Ready    <none>   40m   v1.32.1
```

Посмотрим запущенные поды

```
$ kubectl get pods -A

NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-768847b69f-889xt             1/1     Running   0          44m
kube-system   coredns-768847b69f-fq7vr             1/1     Running   0          40m
kube-system   ip-masq-agent-8kjcj                  1/1     Running   0          41m
kube-system   ip-masq-agent-d8nlc                  1/1     Running   0          40m
kube-system   ip-masq-agent-xvlc7                  1/1     Running   0          40m
kube-system   kube-dns-autoscaler-66b55897-dwtfw   1/1     Running   0          44m
kube-system   kube-proxy-646zw                     1/1     Running   0          40m
kube-system   kube-proxy-d6nr2                     1/1     Running   0          41m
kube-system   kube-proxy-ktbfw                     1/1     Running   0          40m
kube-system   metrics-server-8689cb9795-f5hr8      1/1     Running   0          44m
kube-system   metrics-server-8689cb9795-ptvvf      1/1     Running   0          44m
kube-system   npd-v0.8.0-gwpcb                     1/1     Running   0          40m
kube-system   npd-v0.8.0-h8d78                     1/1     Running   0          40m
kube-system   npd-v0.8.0-wchlc                     1/1     Running   0          41m
kube-system   yc-disk-csi-node-v2-dpl6k            6/6     Running   0          40m
kube-system   yc-disk-csi-node-v2-j7xtk            6/6     Running   0          41m
kube-system   yc-disk-csi-node-v2-lvhlx            6/6     Running   0          40m
```

Заглянем в конфигурационный файл

```
$ cat ~/.kube/config 

apiVersion: v1
clusters:
...
...
...
- cluster:
    certificate-authority-data: LS0t...tCg==
    server: https://158.160.191.253
  name: yc-managed-k8s-catqjjk9ql50jp2qep42
contexts:
...
...
...
- context:
    cluster: yc-managed-k8s-catqjjk9ql50jp2qep42
    user: yc-managed-k8s-catqjjk9ql50jp2qep42
  name: yc-k8s-regional
current-context: yc-k8s-regional
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: LS...0K
    client-key-data: LS0...tCg==
- name: sergey
  user:
    client-certificate-data: LS0...S0K
    client-key-data: LS0...LQo=
- name: yc-managed-k8s-catqjjk9ql50jp2qep42
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - k8s
      - create-token
      - --profile=default
      command: /home/sergey/yandex-cloud/bin/yc
      env: null
      provideClusterInfo: false
```

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

### Деплой инфраструктуры в terraform pipeline

1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform
---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

