#  08-ansible-03-yandex Ansible-Playbook

Плейбук для выполнения домашнего задания Нетологии к занятию "Использование Ansible" модуля "Система управления конфигурациями" (08-ansible-03-yandex)

## play: Установка NGINX
Play инсталляции NGINX выполняется для группы хостов `lighthouse`.
Play адаптирован для установки на deb-based дистрибутивы.
Действия:
1. Добавление репозитория
2. Установка NGINX из репозитория
3. Создание конфигурации по шаблону [templates/nginx.conf.j2](templates/nginx.conf.j2)

## play: Установка Lighthouse
Play инсталляции Lighthouse выполняется для группы хостов `lighthouse`.
Play адаптирован для установки на deb-based дистрибутивы.
Действия:
1. Скачивание исходников Lighthouse из GitHub в указанную директорию
2. Создание конфигурации Lighthouse для NGINX по шаблону [templates/lighthouse.conf.j2](templates/lighthouse.conf.j2)


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

Список хостов (inventory) должен включать группы `clickhouse` и `veсtor`. Пример: [prod.example.yml](inventory/prod.yml)

Для изменения параметров установки Clickhouse необходимо внести изменения в файл [clickhouse vars.yml](group_vars/clickhouse/vars.yml).
- `clickhouse_version`: версия релиза Clickhouse (по умолчанию 22.3.3.44)
- `clickhouse_packages`: список пакетов для скачивания

Для изменения параметров установки Vector необходимо внести изменения в файл [vector vars.yml](group_vars/vector/vars.yml).
- `vector_version`: версия релиза Vector (по умолчанию 0.34.1)
- `vector_architecture`: архитектура (по умолчанию x86_64)

Для изменения параметров установки Lighthouse необходимо внести изменения в файл [lighthouse vars.yml](group_vars/lighthouse/vars.yml).
- `lighthouse_vcs`: исходный код (по умолчанию https://github.com/VKCOM/lighthouse.git)
- `lighthouse_location`: расположение Lighthouse (по умолчанию /var/www/lighthouse)

### Требования

- **Ansible 2.11+**

### Теги
- clickhouse
- vector
- lighthouse

### Запуск

`ansible-playbook -i inventory/prod.yml playbook.yml`, где:
- `inventory/prod.yml` - путь к ansible Inventory 
- `playbook.yml` - путь к ansible Playbook