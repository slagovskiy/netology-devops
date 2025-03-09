# 02-playbook Ansible-Playbook

Плейбук для выполнения домашнего задания Нетологии к занятию "Работа с Playbook" модуля "Система управления конфигурациями" (02-playbook)

## play: Установка Clickhouse
Play для установки Clickhouse выполняется для группы хостов `clickhouse`.
Play адаптирован для установки на rpm-based дистрибутив ВМ и установку Clickhouse в single-node режиме.
Действия: 
1. Скачивание .rpm-пакетов (`noarch` или `x86_64`)
2. Инсталляция дистрибутива
3. Корректировка конфигурации (listen address)
4. Запуск сервиса Clickhouse
5. Создание базы `logs`

## play: Установка Vector
Play для установки Clickhouse выполняется для группы хостов `vector`.
Play адаптирован для установки на deb-based дистрибутивы.
Действия:
1. Создание группы и пользователя `vector`
2. Создание каталогов для дистрибутива и хранения данных
3. Скачивание архива с дистрибутивом, распаковка
4. Создание конфигурации Vector по шаблону [templates/vector.yaml.j2](templates/vector.yaml.j2) с коннектом по умолчанию к Clickhouse
5. Создание systemd unit и запуск сервиса

### Конфигурация

Список хостов (inventory) должен включать группы `clickhouse` и `veсtor`. Пример: [prod.yml](inventory/prod.yml)

Для изменения параметров установки Clickhouse необходимо внести изменения в файл [clickhouse vars.yml](group_vars/clickhouse/vars.yml).
- `clickhouse_version`: версия релиза Clickhouse (по умолчанию 22.3.3.44)
- `clickhouse_packages`: список пакеов для скачивания

Для изменения параметров установки Vector необходимо внести изменения в файл [vector vars.yml](group_vars/vector/vars.yml).
- `vector_version`: версия релиза Vector (по умолчанию 0.34.1)
- `vector_architecture`: архитектура (по умолчанию x86_64)

### Требования

- **Ansible 2.11+**

### Теги
- clickhouse
- vector

### Запуск

`ansible-playbook -i inventory/prod.yml playbook.yml`, где:
- `inventory/prod.yml` - путь к ansible Inventory 
- `playbook.yml` - путь к ansible Playbook