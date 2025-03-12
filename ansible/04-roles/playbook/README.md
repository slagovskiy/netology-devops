# 08-ansible-04-role Ansible-Playbook

Плейбук для выполнения домашнего задания Нетологии к занятию "Работа с roles" модуля "Система управления конфигурациями" (08-ansible-04-role)

## Описание

Плейбук состоит из нескольких play, устанавливающий сервисы Clickhouse, Vector и Lighthouse на группы хостов с помощью соответствующих ролей Ansible.

## Зависимости

Описаны в файле [requirements.yml](requirements.yml)

## Конфигурация

Список хостов (inventory) должен включать группы `lighthouse`, `clickhouse` и `veсtor`. Пример: [prod.yml](inventory/prod.example.yml)

Для изменения параметров Clickhouse можно переопределить дефолтные переменные роли `ansible-clickhouse`. Полный список переменных доступен в описании ролей. Базовая конфигурация определена в файле [clickhouse vars.yml](group_vars/clickhouse/vars.yml):

| *Variable* | *Description* |
| - | - |
| clickhouse_version | Версия дистрибутива |
| clickhouse_listen_host_default | Адрес для запросов |
| clickhouse_networks_default | Доступные подсети для дефолтных профилей пользователя |
| clickhouse_dbs_default | БД для создания по умолчанию |

Для изменения параметров Vector можно переопределить дефолтные переменные роли `ansible_role_vector`. Полный список переменных доступен в описании ролей. Базовая конфигурация определена в файле [vector vars.yml](group_vars/vector/vars.yml):

| *Variable* | *Description* |
| - | - |
| vector_version | Версия дистрибутива |
| vector_endpoint_clickhouse | Адрес Clickhouse API |
| vector_endpoint_clickhouse_table | Таблица по умолчанию |

Для изменения параметров Lighthouse можно переопределить дефолтные переменные роли `ansible_role_lighthouse` и её зависимости `nginxinc.nginx`. Полный список переменных доступен в описании ролей. Базовая конфигурация определена в файле [lighthouse vars.yml](group_vars/lighthouse/vars.yml).

| *Variable* | *Description* |
| - | - |
| lighthouse_location | Расположение файлов сервера Lighthouse |

### Требования

- **Ansible 2.11+**

### Теги

- clickhouse
- vector
- lighthouse

### Запуск

1. Установить роли: `ansible-galaxy install -r requirements.yml -p roles`
2. Запуск плейбука: `ansible-playbook -i inventory/prod.yml playbook.yml`, где:

    - `inventory/prod.yml` - путь к ansible Inventory
    - `playbook.yml` - путь к ansible Playbook
