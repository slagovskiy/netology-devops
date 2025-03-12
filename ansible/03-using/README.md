# Домашнее задание к занятию 3 «Использование Ansible»

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.
2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
4. Подготовьте свой inventory-файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.


---

### init

```
$ terraform apply

...
...

module.vpc_prod.yandex_vpc_network.vpc: Creating...
module.vpc_prod.yandex_vpc_network.vpc: Creation complete after 3s [id=enpu2vd7bl76do6lu64e]
module.vpc_prod.yandex_vpc_subnet.subnet["ru-central1-a"]: Creating...
module.vpc_prod.yandex_vpc_subnet.subnet["ru-central1-a"]: Creation complete after 0s [id=e9b3ib373eq5rdj5ikci]
module.vectors.yandex_compute_instance.vm[1]: Creating...
module.lighthouse.yandex_compute_instance.vm[0]: Creating...
module.vectors.yandex_compute_instance.vm[0]: Creating...
module.clickhouse.yandex_compute_instance.vm[0]: Creating...
module.lighthouse.yandex_compute_instance.vm[0]: Still creating... [10s elapsed]
module.vectors.yandex_compute_instance.vm[0]: Still creating... [10s elapsed]
module.vectors.yandex_compute_instance.vm[1]: Still creating... [10s elapsed]
module.clickhouse.yandex_compute_instance.vm[0]: Still creating... [10s elapsed]
module.vectors.yandex_compute_instance.vm[1]: Still creating... [20s elapsed]
module.vectors.yandex_compute_instance.vm[0]: Still creating... [20s elapsed]
module.lighthouse.yandex_compute_instance.vm[0]: Still creating... [20s elapsed]
module.clickhouse.yandex_compute_instance.vm[0]: Still creating... [20s elapsed]
module.lighthouse.yandex_compute_instance.vm[0]: Still creating... [30s elapsed]
module.vectors.yandex_compute_instance.vm[1]: Still creating... [30s elapsed]
module.vectors.yandex_compute_instance.vm[0]: Still creating... [30s elapsed]
module.clickhouse.yandex_compute_instance.vm[0]: Still creating... [30s elapsed]
module.clickhouse.yandex_compute_instance.vm[0]: Creation complete after 40s [id=fhmclkmoepb3a6l8lm8t]
module.vectors.yandex_compute_instance.vm[0]: Still creating... [40s elapsed]
module.lighthouse.yandex_compute_instance.vm[0]: Still creating... [40s elapsed]
module.vectors.yandex_compute_instance.vm[1]: Still creating... [40s elapsed]
module.vectors.yandex_compute_instance.vm[1]: Creation complete after 41s [id=fhmuhig4gu5g8sucpllh]
module.lighthouse.yandex_compute_instance.vm[0]: Still creating... [50s elapsed]
module.vectors.yandex_compute_instance.vm[0]: Still creating... [50s elapsed]
module.lighthouse.yandex_compute_instance.vm[0]: Creation complete after 52s [id=fhmm07bj5k4tf1hrfo9f]
module.vectors.yandex_compute_instance.vm[0]: Creation complete after 52s [id=fhm47hhs0h056hfih29f]
local_file.inventory: Creating...
local_file.inventory: Creation complete after 0s [id=a40fc0f7f27461cb48dd0a9482852773e4698d8c]

```


### inventory

```
$ cat inventory/prod.yml 
---
all:
  children:
    clickhouse:
      hosts:
        clickhouse-0.ru-central1.internal:
          ansible_host: 158.160.45.124

    vector:
      hosts:
        vector-0.ru-central1.internal:
          ansible_host: 158.160.61.133
        vector-1.ru-central1.internal:
          ansible_host: 158.160.54.72

    lighthouse:
      hosts:
        lighthouse-0.ru-central1.internal:
          ansible_host: 89.169.152.71
```

### lint

```
$ ansible-lint playbook.yml 

Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```

### check

```
$ ansible-playbook -i inventory/prod.yml playbook.yml --check

PLAY [Install NGINX] ************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [lighthouse-0.ru-central1.internal]

TASK [NGINX | Add nginx apt-key] ************************************************************************************************************************************************************************************************************************
changed: [lighthouse-0.ru-central1.internal]

TASK [NGINX | Add nginx apt repository] *****************************************************************************************************************************************************************************************************************
changed: [lighthouse-0.ru-central1.internal]

TASK [NGINX | Install] **********************************************************************************************************************************************************************************************************************************
changed: [lighthouse-0.ru-central1.internal]

TASK [NGINX | Create general config] ********************************************************************************************************************************************************************************************************************
changed: [lighthouse-0.ru-central1.internal]

RUNNING HANDLER [NGINX | Start nginx] *******************************************************************************************************************************************************************************************************************
fatal: [lighthouse-0.ru-central1.internal]: FAILED! => {"changed": false, "msg": "Could not find the requested service nginx: host"}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
lighthouse-0.ru-central1.internal : ok=5    changed=4    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

```

### diff-0

```
...
...

LAY RECAP **********************************************************************************************************************************************************************************************************************************************
clickhouse-0.ru-central1.internal : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-0.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-0.ru-central1.internal : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-1.ru-central1.internal : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

### diff-1

```
...
...
LAY RECAP ********************************************************************************************************************************************************
clickhouse-0.ru-central1.internal : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-0.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-0.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-1.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

```
$ curl 89.169.152.71
<html>
<head>
	<title>LightHouse</title>
	<link href="css/bootstrap.css" rel="stylesheet" media="screen">
```

[playbook.md](./playbook/playbook.md)
