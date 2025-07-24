# Домашнее задание к занятию «Вычислительные мощности. Балансировщики нагрузки»

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашних заданий.

---
## Задание 1. Yandex Cloud 

**Что нужно сделать**

1. Создать бакет Object Storage и разместить в нём файл с картинкой:

 - Создать бакет в Object Storage с произвольным именем (например, _имя_студента_дата_).
 - Положить в бакет файл с картинкой.
 - Сделать файл доступным из интернета.
 
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:

 - Создать Instance Group с тремя ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать `image_id = fd827b91d99psvq5fjit`.
 - Для создания стартовой веб-страницы рекомендуется использовать раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata).
 - Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
 - Настроить проверку состояния ВМ.
 
3. Подключить группу к сетевому балансировщику:

 - Создать сетевой балансировщик.
 - Проверить работоспособность, удалив одну или несколько ВМ.
4. (дополнительно)* Создать Application Load Balancer с использованием Instance group и проверкой состояния.

Полезные документы:

- [Compute instance group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance_group).
- [Network Load Balancer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer).
- [Группа ВМ с сетевым балансировщиком](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer).

#### Решение

[variables.tf](./terraform/variables.tf) переменные с параметрами для всех объектов. Значения (только публичные) заданы в [public.auto.tfvars](./terraform/public.auto.tfvars)  

[network.tf](./terraform/network.tf) описано создание VPC, subnets и load balancer

[main.tf](./terraform/main.tf) создание шаблона cloud-init, получение images id и создание intance group, сервисного аккаунта для него

[storage.tf](./terraform/storage.tf) создается bucket, сервисный аккаунт для управления и размещение object

terraform apply

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ terraform apply
data.yandex_compute_image.lamp: Reading...

....
....
....


Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_iam_service_account.storage-sa: Creating...
yandex_iam_service_account.lamp-sa: Creating...
yandex_vpc_network.vpc: Creating...
yandex_iam_service_account.storage-sa: Creation complete after 2s [id=ajeovcfl0ice9ck10d99]
yandex_iam_service_account_static_access_key.storage-sa: Creating...
yandex_resourcemanager_cloud_iam_member.bucket-editor: Creating...
yandex_vpc_network.vpc: Creation complete after 3s [id=enp5adnnvmbbj5bjl2a8]
yandex_vpc_subnet.subnets["public"]: Creating...
yandex_iam_service_account_static_access_key.storage-sa: Creation complete after 2s [id=ajeegflqnpmfbm5420ks]
yandex_iam_service_account.lamp-sa: Creation complete after 4s [id=aje3of71a0iakbeime1l]
yandex_resourcemanager_folder_iam_member.lamp-editor: Creating...
yandex_vpc_subnet.subnets["public"]: Creation complete after 1s [id=e9bfkdpen7ina0meq096]
yandex_resourcemanager_cloud_iam_member.bucket-editor: Creation complete after 5s [id=b1g10hm1l50eocmema3h/storage.editor/serviceAccount:ajeovcfl0ice9ck10d99]
yandex_storage_bucket.slagovskiy: Creating...
yandex_resourcemanager_folder_iam_member.lamp-editor: Creation complete after 3s [id=b1gghlg0i9r4su8up17l/editor/serviceAccount:aje3of71a0iakbeime1l]
yandex_storage_bucket.slagovskiy: Still creating... [10s elapsed]
yandex_storage_bucket.slagovskiy: Creation complete after 16s [id=slagovskiy-20250724]
data.template_file.web_cloudinit: Reading...
yandex_storage_object.object: Creating...
data.template_file.web_cloudinit: Read complete after 0s [id=9c4cfb73362695031c69e1e8bb374dc5c1eda10756a25269cc958dbb12ef5b97]
yandex_compute_instance_group.lamp: Creating...
yandex_storage_object.object: Creation complete after 0s [id=image.jpg]
yandex_compute_instance_group.lamp: Still creating... [10s elapsed]
yandex_compute_instance_group.lamp: Still creating... [20s elapsed]
yandex_compute_instance_group.lamp: Still creating... [30s elapsed]
yandex_compute_instance_group.lamp: Still creating... [40s elapsed]
yandex_compute_instance_group.lamp: Still creating... [50s elapsed]
yandex_compute_instance_group.lamp: Still creating... [1m0s elapsed]
yandex_compute_instance_group.lamp: Still creating... [1m10s elapsed]
yandex_compute_instance_group.lamp: Still creating... [1m20s elapsed]
yandex_compute_instance_group.lamp: Still creating... [1m30s elapsed]
yandex_compute_instance_group.lamp: Still creating... [1m40s elapsed]
yandex_compute_instance_group.lamp: Still creating... [1m50s elapsed]
yandex_compute_instance_group.lamp: Still creating... [2m0s elapsed]
yandex_compute_instance_group.lamp: Still creating... [2m10s elapsed]
yandex_compute_instance_group.lamp: Still creating... [2m20s elapsed]
yandex_compute_instance_group.lamp: Still creating... [2m30s elapsed]
yandex_compute_instance_group.lamp: Still creating... [2m40s elapsed]
yandex_compute_instance_group.lamp: Still creating... [2m50s elapsed]
yandex_compute_instance_group.lamp: Still creating... [3m0s elapsed]
yandex_compute_instance_group.lamp: Still creating... [3m10s elapsed]
yandex_compute_instance_group.lamp: Creation complete after 3m11s [id=cl13pccfrs7pjh0crt7t]
yandex_lb_network_load_balancer.lb: Creating...
yandex_lb_network_load_balancer.lb: Creation complete after 5s [id=enpr00mt5laei8kcibfm]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

lb_ip = [
  "158.160.154.172",
]

```

Проверка

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ curl 158.160.154.172

<html><img src="http://slagovskiy-20250724.storage.yandexcloud.net/image.jpg"/></html>
```

![](./2025-07-24_17-10-07.png)

Бакет

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc storage buckets list

+---------------------+----------------------+------------+-----------------------+---------------------+
|        NAME         |      FOLDER ID       |  MAX SIZE  | DEFAULT STORAGE CLASS |     CREATED AT      |
+---------------------+----------------------+------------+-----------------------+---------------------+
| slagovskiy-20250724 | b1gghlg0i9r4su8up17l | 1073741824 | STANDARD              | 2025-07-24 10:01:13 |
+---------------------+----------------------+------------+-----------------------+---------------------+
```

Ресурсы

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc load-balancer network-load-balancer list

+----------------------+------------+-------------+----------+----------------+------------------------+--------+
|          ID          |    NAME    |  REGION ID  |   TYPE   | LISTENER COUNT | ATTACHED TARGET GROUPS | STATUS |
+----------------------+------------+-------------+----------+----------------+------------------------+--------+
| enpr00mt5laei8kcibfm | network-lb | ru-central1 | EXTERNAL |              1 | enpdkks2koapcd0vcmk3   | ACTIVE |
+----------------------+------------+-------------+----------+----------------+------------------------+--------+



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc load-balancer network-load-balancer get network-lb

id: enpr00mt5laei8kcibfm
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T10:04:40Z"
name: network-lb
region_id: ru-central1
status: ACTIVE
type: EXTERNAL
listeners:
  - name: network-lb-listener
    address: 158.160.154.172
    port: "80"
    protocol: TCP
    target_port: "80"
    ip_version: IPV4
attached_target_groups:
  - target_group_id: enpdkks2koapcd0vcmk3
    health_checks:
      - name: http
        interval: 2s
        timeout: 1s
        unhealthy_threshold: "2"
        healthy_threshold: "2"
        http_options:
          port: "80"
          path: /index.html

```

Целевая группа

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc load-balancer target-group list

+----------------------+---------+---------------------+-------------+--------------+
|          ID          |  NAME   |       CREATED       |  REGION ID  | TARGET COUNT |
+----------------------+---------+---------------------+-------------+--------------+
| enpdkks2koapcd0vcmk3 | lamp-tg | 2025-07-24 10:01:32 | ru-central1 |            3 |
+----------------------+---------+---------------------+-------------+--------------+



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc load-balancer target-group get lamp-tg

id: enpdkks2koapcd0vcmk3
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T10:01:32Z"
name: lamp-tg
description: Целевая группа Network Load Balancer
region_id: ru-central1
targets:
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.23
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.24
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.33
```

VMs

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc compute instance list

+----------------------+---------------------------+---------------+---------+-------------+---------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  | EXTERNAL IP |  INTERNAL IP  |
+----------------------+---------------------------+---------------+---------+-------------+---------------+
| fhm56ml9mbj1ve75ccsn | cl13pccfrs7pjh0crt7t-ehum | ru-central1-a | RUNNING |             | 192.168.10.24 |
| fhm6nc4pq3f1q69rokb4 | cl13pccfrs7pjh0crt7t-elyb | ru-central1-a | RUNNING |             | 192.168.10.33 |
| fhmk9o6n1qqqb2gogfl3 | cl13pccfrs7pjh0crt7t-afet | ru-central1-a | RUNNING |             | 192.168.10.23 |
+----------------------+---------------------------+---------------+---------+-------------+---------------+
```



Останавливаем одну машину и проверяем доступность.

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc compute instance list

+----------------------+---------------------------+---------------+---------+-------------+---------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  | EXTERNAL IP |  INTERNAL IP  |
+----------------------+---------------------------+---------------+---------+-------------+---------------+
| fhm56ml9mbj1ve75ccsn | cl13pccfrs7pjh0crt7t-ehum | ru-central1-a | RUNNING |             | 192.168.10.24 |
| fhm6nc4pq3f1q69rokb4 | cl13pccfrs7pjh0crt7t-elyb | ru-central1-a | RUNNING |             | 192.168.10.33 |
| fhmk9o6n1qqqb2gogfl3 | cl13pccfrs7pjh0crt7t-afet | ru-central1-a | RUNNING |             | 192.168.10.23 |
+----------------------+---------------------------+---------------+---------+-------------+---------------+




sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc compute instance stop fhm56ml9mbj1ve75ccsn

done (19s)



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc compute instance list
+----------------------+---------------------------+---------------+---------+-------------+---------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  | EXTERNAL IP |  INTERNAL IP  |
+----------------------+---------------------------+---------------+---------+-------------+---------------+
| fhm56ml9mbj1ve75ccsn | cl13pccfrs7pjh0crt7t-ehum | ru-central1-a | STOPPED |             | 192.168.10.24 |
| fhm6nc4pq3f1q69rokb4 | cl13pccfrs7pjh0crt7t-elyb | ru-central1-a | RUNNING |             | 192.168.10.33 |
| fhmk9o6n1qqqb2gogfl3 | cl13pccfrs7pjh0crt7t-afet | ru-central1-a | RUNNING |             | 192.168.10.23 |
+----------------------+---------------------------+---------------+---------+-------------+---------------+



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc load-balancer target-group get lamp-tg

id: enpdkks2koapcd0vcmk3
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T10:01:32Z"
name: lamp-tg
description: Целевая группа Network Load Balancer
region_id: ru-central1
targets:
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.23
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.33



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ curl 158.160.154.172

<html><img src="http://slagovskiy-20250724.storage.yandexcloud.net/image.jpg"/></html>
```

Ресурс доступен

Удалим удалим из группы доступности еще одну машину и остановим ее.

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc load-balancer target-group remove-targets --target subnet-id=e9bfkdpen7ina0meq096,address=192.168.10.33 --name lamp-tg

done (2s)
id: enpdkks2koapcd0vcmk3
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T10:01:32Z"
name: lamp-tg
description: Целевая группа Network Load Balancer
region_id: ru-central1
targets:
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.23
  - subnet_id: e9bfkdpen7ina0meq096
    address: 192.168.10.24



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc compute instance stop fhm6nc4pq3f1q69rokb4

done (20s)



sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ yc compute instance list

+----------------------+---------------------------+---------------+----------+-------------+---------------+
|          ID          |           NAME            |    ZONE ID    |  STATUS  | EXTERNAL IP |  INTERNAL IP  |
+----------------------+---------------------------+---------------+----------+-------------+---------------+
| fhm56ml9mbj1ve75ccsn | cl13pccfrs7pjh0crt7t-ehum | ru-central1-a | STOPPED          | 192.168.10.24 |
| fhm6nc4pq3f1q69rokb4 | cl13pccfrs7pjh0crt7t-elyb | ru-central1-a | STOPPED  |             | 192.168.10.33 |
| fhmk9o6n1qqqb2gogfl3 | cl13pccfrs7pjh0crt7t-afet | ru-central1-a | RUNNING  |             | 192.168.10.23 |
+----------------------+---------------------------+---------------+----------+-------------+---------------+

sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ curl 158.160.154.172

<html><img src="http://slagovskiy-20250724.storage.yandexcloud.net/image.jpg"/></html>
```


```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-02/terraform$ terraform destroy

....
....
....


Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

yandex_storage_object.object: Destroying... [id=image.jpg]
yandex_lb_network_load_balancer.lb: Destroying... [id=enpr00mt5laei8kcibfm]
yandex_storage_object.object: Destruction complete after 1s
yandex_lb_network_load_balancer.lb: Destruction complete after 3s
yandex_compute_instance_group.lamp: Destroying... [id=cl13pccfrs7pjh0crt7t]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 10s elapsed]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 20s elapsed]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 30s elapsed]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 40s elapsed]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 50s elapsed]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 1m0s elapsed]
yandex_compute_instance_group.lamp: Still destroying... [id=cl13pccfrs7pjh0crt7t, 1m10s elapsed]
yandex_compute_instance_group.lamp: Destruction complete after 1m14s
yandex_resourcemanager_folder_iam_member.lamp-editor: Destroying... [id=b1gghlg0i9r4su8up17l/editor/serviceAccount:aje3of71a0iakbeime1l]
yandex_storage_bucket.slagovskiy: Destroying... [id=slagovskiy-20250724]
yandex_vpc_subnet.subnets["public"]: Destroying... [id=e9bfkdpen7ina0meq096]
yandex_vpc_subnet.subnets["public"]: Destruction complete after 2s
yandex_vpc_network.vpc: Destroying... [id=enp5adnnvmbbj5bjl2a8]
yandex_vpc_network.vpc: Destruction complete after 1s
yandex_resourcemanager_folder_iam_member.lamp-editor: Destruction complete after 3s
yandex_iam_service_account.lamp-sa: Destroying... [id=aje3of71a0iakbeime1l]
yandex_iam_service_account.lamp-sa: Destruction complete after 3s
yandex_storage_bucket.slagovskiy: Still destroying... [id=slagovskiy-20250724, 10s elapsed]
yandex_storage_bucket.slagovskiy: Destruction complete after 12s
yandex_resourcemanager_cloud_iam_member.bucket-editor: Destroying... [id=b1g10hm1l50eocmema3h/storage.editor/serviceAccount:ajeovcfl0ice9ck10d99]
yandex_iam_service_account_static_access_key.storage-sa: Destroying... [id=ajeegflqnpmfbm5420ks]
yandex_iam_service_account_static_access_key.storage-sa: Destruction complete after 0s
yandex_resourcemanager_cloud_iam_member.bucket-editor: Destruction complete after 3s
yandex_iam_service_account.storage-sa: Destroying... [id=ajeovcfl0ice9ck10d99]
yandex_iam_service_account.storage-sa: Destruction complete after 3s

Destroy complete! Resources: 11 destroyed.
```