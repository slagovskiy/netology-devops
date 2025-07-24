# Домашнее задание к занятию «Организация сети» "Макарцев Александр Владимирович"

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашнее задание по теме «Облачные провайдеры и синтаксис Terraform». Заранее выберите регион (в случае AWS) и зону.

---
### Задание 1. Yandex Cloud 

**Что нужно сделать**

1. Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.

Resource Terraform для Yandex Cloud:

- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

#### Решение

[variables.tf](./terraform/variables.tf) переменные с параметрами для всех объектов. Значения (только публичные) заданы в [public.auto.tfvars](./terraform/public.auto.tfvars)

[network.tf](./terraform/network.tf) описано создание VPC, subnets и route table.  

[main.tf](./terraform/main.tf) создание шаблона cloud-init, получение images id и compute instance через for_each



Запускаем

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ terraform apply
data.template_file.web_cloudinit: Reading...
data.template_file.web_cloudinit: Read complete after 0s 

....
....
....


Plan: 7 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.vpc: Creating...
yandex_vpc_network.vpc: Creation complete after 7s [id=enpivhip5blp3evssq9s]
yandex_vpc_route_table.nat_route: Creating...
yandex_vpc_route_table.nat_route: Creation complete after 2s [id=enp1caqgo0jo3hsaf3ru]
yandex_vpc_subnet.subnets["private"]: Creating...
yandex_vpc_subnet.subnets["public"]: Creating...
yandex_vpc_subnet.subnets["private"]: Creation complete after 1s [id=e9bvf1etnt72flb2vq6d]
yandex_vpc_subnet.subnets["public"]: Creation complete after 1s [id=e9bthqs1kcft8td93u7g]
yandex_compute_instance.vms["public"]: Creating...
yandex_compute_instance.vms["nat"]: Creating...
yandex_compute_instance.vms["private"]: Creating...
yandex_compute_instance.vms["public"]: Still creating... [10s elapsed]
yandex_compute_instance.vms["private"]: Still creating... [10s elapsed]
yandex_compute_instance.vms["nat"]: Still creating... [10s elapsed]
yandex_compute_instance.vms["public"]: Still creating... [20s elapsed]
yandex_compute_instance.vms["private"]: Still creating... [20s elapsed]
yandex_compute_instance.vms["nat"]: Still creating... [20s elapsed]
yandex_compute_instance.vms["public"]: Still creating... [30s elapsed]
yandex_compute_instance.vms["private"]: Still creating... [30s elapsed]
yandex_compute_instance.vms["nat"]: Still creating... [30s elapsed]
yandex_compute_instance.vms["public"]: Creation complete after 40s [id=fhm60heosk4pq0qcis2q]
yandex_compute_instance.vms["private"]: Still creating... [40s elapsed]
yandex_compute_instance.vms["nat"]: Still creating... [40s elapsed]
yandex_compute_instance.vms["private"]: Still creating... [50s elapsed]
yandex_compute_instance.vms["nat"]: Still creating... [50s elapsed]
yandex_compute_instance.vms["private"]: Creation complete after 55s [id=fhmja9qenacvlv5d5anb]
yandex_compute_instance.vms["nat"]: Creation complete after 56s [id=fhmfi3iet00tv12q0d0m]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

Созданные ресурсы

vpc subnet

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc vpc subnet list

+----------------------+---------+----------------------+----------------------+---------------+-------------------+
|          ID          |  NAME   |      NETWORK ID      |    ROUTE TABLE ID    |     ZONE      |       RANGE       |
+----------------------+---------+----------------------+----------------------+---------------+-------------------+
| e9bthqs1kcft8td93u7g | public  | enpivhip5blp3evssq9s |                      | ru-central1-a | [192.168.10.0/24] |
| e9bvf1etnt72flb2vq6d | private | enpivhip5blp3evssq9s | enp1caqgo0jo3hsaf3ru | ru-central1-a | [192.168.20.0/24] |
+----------------------+---------+----------------------+----------------------+---------------+-------------------+


sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc vpc subnet get public

id: e9bthqs1kcft8td93u7g
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T08:22:34Z"
name: public
network_id: enpivhip5blp3evssq9s
zone_id: ru-central1-a
v4_cidr_blocks:
  - 192.168.10.0/24


sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc vpc subnet get private

id: e9bvf1etnt72flb2vq6d
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T08:22:33Z"
name: private
network_id: enpivhip5blp3evssq9s
zone_id: ru-central1-a
v4_cidr_blocks:
  - 192.168.20.0/24
route_table_id: enp1caqgo0jo3hsaf3ru
```

vpc route-table

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc vpc route-table list

+----------------------+-----------+-------------+----------------------+
|          ID          |   NAME    | DESCRIPTION |      NETWORK-ID      |
+----------------------+-----------+-------------+----------------------+
| enp1caqgo0jo3hsaf3ru | nat_route |             | enpivhip5blp3evssq9s |
+----------------------+-----------+-------------+----------------------+


sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc vpc route-table get nat_route

id: enp1caqgo0jo3hsaf3ru
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T08:22:31Z"
name: nat_route
network_id: enpivhip5blp3evssq9s
static_routes:
  - destination_prefix: 0.0.0.0/0
    next_hop_address: 192.168.10.254
```

compute instance

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc compute instance list

+----------------------+---------+---------------+---------+---------------+----------------+
|          ID          |  NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP  |  INTERNAL IP   |
+----------------------+---------+---------------+---------+---------------+----------------+
| fhm60heosk4pq0qcis2q | public  | ru-central1-a | RUNNING | 51.250.75.12  | 192.168.10.7   |
| fhmfi3iet00tv12q0d0m | nat     | ru-central1-a | RUNNING | 89.169.144.85 | 192.168.10.254 |
| fhmja9qenacvlv5d5anb | private | ru-central1-a | RUNNING |               | 192.168.20.7   |
+----------------------+---------+---------------+---------+---------------+----------------+



sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc compute instance get public

id: fhm60heosk4pq0qcis2q
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T08:22:35Z"
name: public
zone_id: ru-central1-a
platform_id: standard-v1
resources:
  memory: "2147483648"
  cores: "2"
  core_fraction: "100"
status: RUNNING
metadata_options:
  gce_http_endpoint: ENABLED
  aws_v1_http_endpoint: ENABLED
  gce_http_token: ENABLED
  aws_v1_http_token: DISABLED
boot_disk:
  mode: READ_WRITE
  device_name: fhma38m18lksv287r358
  auto_delete: true
  disk_id: fhma38m18lksv287r358
network_interfaces:
  - index: "0"
    mac_address: d0:0d:60:45:d8:e5
    subnet_id: e9bthqs1kcft8td93u7g
    primary_v4_address:
      address: 192.168.10.7
      one_to_one_nat:
        address: 51.250.75.12
        ip_version: IPV4
serial_port_settings:
  ssh_authorization: OS_LOGIN
gpu_settings: {}
fqdn: public.ru-central1.internal
scheduling_policy: {}
network_settings:
  type: STANDARD
placement_policy: {}
hardware_generation:
  legacy_features:
    pci_topology: PCI_TOPOLOGY_V2



sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc compute instance get nat

id: fhmfi3iet00tv12q0d0m
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T08:22:35Z"
name: nat
zone_id: ru-central1-a
platform_id: standard-v1
resources:
  memory: "2147483648"
  cores: "2"
  core_fraction: "100"
status: RUNNING
metadata_options:
  gce_http_endpoint: ENABLED
  aws_v1_http_endpoint: ENABLED
  gce_http_token: ENABLED
  aws_v1_http_token: DISABLED
boot_disk:
  mode: READ_WRITE
  device_name: fhmv1eock90e8kpmanla
  auto_delete: true
  disk_id: fhmv1eock90e8kpmanla
network_interfaces:
  - index: "0"
    mac_address: d0:0d:f9:0e:4e:e8
    subnet_id: e9bthqs1kcft8td93u7g
    primary_v4_address:
      address: 192.168.10.254
      one_to_one_nat:
        address: 89.169.144.85
        ip_version: IPV4
serial_port_settings:
  ssh_authorization: OS_LOGIN
gpu_settings: {}
fqdn: nat.ru-central1.internal
scheduling_policy: {}
network_settings:
  type: STANDARD
placement_policy: {}
hardware_generation:
  legacy_features:
    pci_topology: PCI_TOPOLOGY_V1



sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ yc compute instance get private

id: fhmja9qenacvlv5d5anb
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-07-24T08:22:35Z"
name: private
zone_id: ru-central1-a
platform_id: standard-v1
resources:
  memory: "2147483648"
  cores: "2"
  core_fraction: "100"
status: RUNNING
metadata_options:
  gce_http_endpoint: ENABLED
  aws_v1_http_endpoint: ENABLED
  gce_http_token: ENABLED
  aws_v1_http_token: DISABLED
boot_disk:
  mode: READ_WRITE
  device_name: fhm4ac62egfua6pouddp
  auto_delete: true
  disk_id: fhm4ac62egfua6pouddp
network_interfaces:
  - index: "0"
    mac_address: d0:0d:13:52:74:eb
    subnet_id: e9bvf1etnt72flb2vq6d
    primary_v4_address:
      address: 192.168.20.7
serial_port_settings:
  ssh_authorization: OS_LOGIN
gpu_settings: {}
fqdn: private.ru-central1.internal
scheduling_policy: {}
network_settings:
  type: STANDARD
placement_policy: {}
hardware_generation:
  legacy_features:
    pci_topology: PCI_TOPOLOGY_V2
```

Подключение к public, проверка доступа в интернет

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-01/terraform$ ssh 51.250.75.12
The authenticity of host '51.250.75.12 (51.250.75.12)' can't be established.
ED25519 key fingerprint is SHA256:uyFA/i4JvQQ6iiaEKM8amZJzqnxQeqT8z8yJyoROEZE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '51.250.75.12' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-216-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Jul 24 08:35:55 UTC 2025

  System load:  0.0               Processes:             107
  Usage of /:   38.0% of 4.20GB   Users logged in:       0
  Memory usage: 9%                IPv4 address for eth0: 192.168.10.7
  Swap usage:   0%


Expanded Security Maintenance for Infrastructure is not enabled.

3 updates can be applied immediately.
3 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

34 additional security updates can be applied with ESM Infra.
Learn more about enabling ESM Infra service for Ubuntu 20.04 at
https://ubuntu.com/20-04



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.



sergey@public:~$ ping -c 5 rambler.ru

PING rambler.ru (81.19.82.1) 56(84) bytes of data.
64 bytes from www.rambler.ru (81.19.82.1): icmp_seq=1 ttl=55 time=4.14 ms
64 bytes from www.rambler.ru (81.19.82.1): icmp_seq=2 ttl=55 time=3.77 ms
64 bytes from www.rambler.ru (81.19.82.1): icmp_seq=3 ttl=55 time=3.65 ms
64 bytes from www.rambler.ru (81.19.82.1): icmp_seq=4 ttl=55 time=3.83 ms
64 bytes from www.rambler.ru (81.19.82.1): icmp_seq=5 ttl=55 time=3.81 ms

--- rambler.ru ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4007ms
rtt min/avg/max/mdev = 3.647/3.840/4.144/0.164 ms
```


Подключение к private через public, проверка доступа в интернет

```
sergey@public:~$ ssh 192.168.20.7
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-216-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Jul 24 08:43:46 UTC 2025

  System load:  0.02              Processes:             111
  Usage of /:   38.0% of 4.20GB   Users logged in:       0
  Memory usage: 10%               IPv4 address for eth0: 192.168.20.7
  Swap usage:   0%


Expanded Security Maintenance for Infrastructure is not enabled.

0 updates can be applied immediately.

34 additional security updates can be applied with ESM Infra.
Learn more about enabling ESM Infra service for Ubuntu 20.04 at
https://ubuntu.com/20-04



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.



sergey@private:~$ ping -c 5 rambler.ru

PING rambler.ru (81.19.82.0) 56(84) bytes of data.
64 bytes from www.rambler.ru (81.19.82.0): icmp_seq=1 ttl=51 time=5.31 ms
64 bytes from www.rambler.ru (81.19.82.0): icmp_seq=2 ttl=51 time=4.00 ms
64 bytes from www.rambler.ru (81.19.82.0): icmp_seq=3 ttl=51 time=4.04 ms
64 bytes from www.rambler.ru (81.19.82.0): icmp_seq=4 ttl=51 time=4.09 ms
64 bytes from www.rambler.ru (81.19.82.0): icmp_seq=5 ttl=51 time=3.99 ms

--- rambler.ru ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4005ms
rtt min/avg/max/mdev = 3.989/4.284/5.308/0.513 ms
```


Проверка, что запрос идёт через NAT

```
sergey@private:~$ traceroute rambler.ru

traceroute to rambler.ru (81.19.82.0), 30 hops max, 60 byte packets
 1  _gateway (192.168.20.1)  0.521 ms  0.420 ms  0.789 ms
 2  * * *
 3  nat.ru-central1.internal (192.168.10.254)  0.837 ms  0.790 ms  0.727 ms
 4  nat.ru-central1.internal (192.168.10.254)  0.747 ms  0.695 ms  0.641 ms
 5  * * *
```

