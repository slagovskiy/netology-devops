# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.

---

```
$ cat inventory/prod.yml 
---
all:
  children:
    clickhouse:
      hosts:
        clickhouse-0.ru-central1.internal:
          ansible_host: 89.169.153.61

    vector:
      hosts:
        vector-0.ru-central1.internal:
          ansible_host: 89.169.134.147
        vector-1.ru-central1.internal:
          ansible_host: 158.160.45.162
```

---

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!

---

```yaml
- name: Install Vector
  hosts: vector
  tags: vector
  become: true
  handlers:
    - name: Restart service Vector, also issue daemon-reload to pick up config changes
      ansible.builtin.systemd_service:
        state: restarted
        daemon_reload: true
        name: vector
        enabled: true
      listen: "restart service"
  tasks:
    - name: Ensure group "vector" exists
      ansible.builtin.group:
        name: vector
        state: present

    - name: Add the user 'vector' with a bash shell, appending the group 'vector' and groups for scraping
      ansible.builtin.user:
        name: vector
        shell: /bin/bash
        groups: syslog,systemd-journal,vector

    - name: Create bin and data directory
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: directory
        mode: "{{ item.mode }}"
        group: "{{ item.group }}"
      loop:
        - { path: "/etc/vector", mode: '0755', group: 'root' }
        - { path: "/var/lib/vector", mode: '0775', group: 'vector' }

    - name: Get Vector package
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-{{ vector_architecture }}-unknown-linux-musl.tar.gz"
        dest: "/tmp/vector-{{ vector_version }}.tar.gz"
        mode: '0644'
      register: archive

    - name: Unarchive Vector package to destination
      ansible.builtin.unarchive:
        src: "{{ archive.dest }}"
        dest: /etc/vector
        remote_src: true
        mode: '0755'
        owner: root
        group: root
      register: unpacked

    - name: Set Vector config from template
      ansible.builtin.template:
        src: vector.yaml.j2
        dest: /etc/vector/vector.yaml
        mode: '0755'

    - name: Copy Vector default unit in systemd (if changed - notify handler)
      ansible.builtin.copy:
        src: "{{ unpacked.dest }}/vector-x86_64-unknown-linux-musl/etc/systemd/vector.service"
        dest: /lib/systemd/system/vector.service
        owner: root
        group: root
        mode: '0755'
        remote_src: true
      register: unit
      notify: restart service

    - name: Create a symbolic links for starting systemd unit and bin
      ansible.builtin.file:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        owner: root
        group: root
        state: link
        mode: "0755"
      loop:
        - { src: "{{ unit.dest }}", dest: '/etc/systemd/system/vector.service' }
        - { src: "{{ unpacked.dest }}/vector-x86_64-unknown-linux-musl/bin/vector", dest: '/usr/bin/vector' }

```

---

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

---

```yaml
---
- name: Install Clickhouse
  hosts: clickhouse
  tags: clickhouse
  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - name: Download Clickhouse distrib
      block:
        - name: Get clickhouse distrib noarch packages
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.noarch.rpm"
            dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
            mode: "0644"
          with_items: "{{ clickhouse_packages }}"
      rescue:
        - name: Get clickhouse distrib x86_64 instead
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-{{ clickhouse_version }}.x86_64.rpm"
            dest: "./clickhouse-common-static-{{ clickhouse_version }}.rpm"
            mode: "0644"
    - name: Install clickhouse packages
      become: true
      ansible.builtin.yum:
        name:
          - clickhouse-common-static-{{ clickhouse_version }}.rpm
          - clickhouse-client-{{ clickhouse_version }}.rpm
          - clickhouse-server-{{ clickhouse_version }}.rpm
      notify: Start clickhouse service
    - name: Set the default listen address
      become: true
      ansible.builtin.lineinfile:
        path: /etc/clickhouse-server/config.xml
        regex: '^.*<listen_host>::</listen_host>'
        line: '    <listen_host>::</listen_host>'
        backrefs: true
    - name: Flush handlers
      ansible.builtin.meta: flush_handlers
    - name: Create database
      ansible.builtin.command: "clickhouse-client -h 0.0.0.0 -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc != 82
      changed_when: create_db.rc == 0

- name: Install Vector
  hosts: vector
  tags: vector
  become: true
  handlers:
    - name: Restart service Vector, also issue daemon-reload to pick up config changes
      ansible.builtin.systemd_service:
        state: restarted
        daemon_reload: true
        name: vector
        enabled: true
      listen: "restart service"
  tasks:
    - name: Ensure group "vector" exists
      ansible.builtin.group:
        name: vector
        state: present

    - name: Add the user 'vector' with a bash shell, appending the group 'vector' and groups for scraping
      ansible.builtin.user:
        name: vector
        shell: /bin/bash
        groups: syslog,systemd-journal,vector

    - name: Create bin and data directory
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: directory
        mode: "{{ item.mode }}"
        group: "{{ item.group }}"
      loop:
        - { path: "/etc/vector", mode: '0755', group: 'root' }
        - { path: "/var/lib/vector", mode: '0775', group: 'vector' }

    - name: Get Vector package
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-{{ vector_architecture }}-unknown-linux-musl.tar.gz"
        dest: "/tmp/vector-{{ vector_version }}.tar.gz"
        mode: '0644'
      register: archive

    - name: Unarchive Vector package to destination
      ansible.builtin.unarchive:
        src: "{{ archive.dest }}"
        dest: /etc/vector
        remote_src: true
        mode: '0755'
        owner: root
        group: root
      register: unpacked

    - name: Set Vector config from template
      ansible.builtin.template:
        src: vector.yaml.j2
        dest: /etc/vector/vector.yaml
        mode: '0755'

    - name: Copy Vector default unit in systemd (if changed - notify handler)
      ansible.builtin.copy:
        src: "{{ unpacked.dest }}/vector-x86_64-unknown-linux-musl/etc/systemd/vector.service"
        dest: /lib/systemd/system/vector.service
        owner: root
        group: root
        mode: '0755'
        remote_src: true
      register: unit
      notify: restart service

    - name: Create a symbolic links for starting systemd unit and bin
      ansible.builtin.file:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        owner: root
        group: root
        state: link
        mode: "0755"
      loop:
        - { src: "{{ unit.dest }}", dest: '/etc/systemd/system/vector.service' }
        - { src: "{{ unpacked.dest }}/vector-x86_64-unknown-linux-musl/bin/vector", dest: '/usr/bin/vector' }
```

---

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

---

```
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] *******************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

TASK [Get clickhouse distrib noarch packages] ***********************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal] => (item=clickhouse-client)
changed: [clickhouse-0.ru-central1.internal] => (item=clickhouse-server)
failed: [clickhouse-0.ru-central1.internal] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.2.3.5-2.rpm", "elapsed": 1, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.2.3.5-2.noarch.rpm"}

TASK [Get clickhouse distrib x86_64 instead] ************************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal]

TASK [Install clickhouse packages] **********************************************************************************************************************************************************************************************************************
fatal: [clickhouse-0.ru-central1.internal]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.2.3.5-2.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.2.3.5-2.rpm' found on system"]}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
clickhouse-0.ru-central1.internal : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0   

```
---

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

---

```
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] *******************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

TASK [Get clickhouse distrib noarch packages] ***********************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal] => (item=clickhouse-client)
changed: [clickhouse-0.ru-central1.internal] => (item=clickhouse-server)
failed: [clickhouse-0.ru-central1.internal] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.2.3.5-2.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.2.3.5-2.noarch.rpm"}

TASK [Get clickhouse distrib x86_64 instead] ************************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal]

TASK [Install clickhouse packages] **********************************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal]

TASK [Set the default listen address] *******************************************************************************************************************************************************************************************************************
--- before: /etc/clickhouse-server/config.xml (content)
+++ after: /etc/clickhouse-server/config.xml (content)
@@ -176,7 +176,7 @@
          - users without password have readonly access.
          See also: https://www.shodan.io/search?query=clickhouse
       -->
-    <!-- <listen_host>::</listen_host> -->
+    <listen_host>::</listen_host>
 
 
     <!-- Same for hosts without support for IPv6: -->

changed: [clickhouse-0.ru-central1.internal]

TASK [Flush handlers] ***********************************************************************************************************************************************************************************************************************************

RUNNING HANDLER [Start clickhouse service] **************************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal]

TASK [Create database] **********************************************************************************************************************************************************************************************************************************
changed: [clickhouse-0.ru-central1.internal]

PLAY [Install Vector] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [vector-1.ru-central1.internal]
ok: [vector-0.ru-central1.internal]

TASK [Ensure group "vector" exists] *********************************************************************************************************************************************************************************************************************
changed: [vector-0.ru-central1.internal]
changed: [vector-1.ru-central1.internal]

TASK [Add the user 'vector' with a bash shell, appending the group 'vector' and groups for scraping] ****************************************************************************************************************************************************
changed: [vector-0.ru-central1.internal]
changed: [vector-1.ru-central1.internal]

TASK [Create bin and data directory] ********************************************************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/etc/vector",
-    "state": "absent"
+    "state": "directory"
 }

changed: [vector-0.ru-central1.internal] => (item={'path': '/etc/vector', 'mode': '0755', 'group': 'root'})
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/etc/vector",
-    "state": "absent"
+    "state": "directory"
 }

changed: [vector-1.ru-central1.internal] => (item={'path': '/etc/vector', 'mode': '0755', 'group': 'root'})
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "group": 0,
-    "mode": "0755",
+    "group": 1002,
+    "mode": "0775",
     "path": "/var/lib/vector",
-    "state": "absent"
+    "state": "directory"
 }

changed: [vector-0.ru-central1.internal] => (item={'path': '/var/lib/vector', 'mode': '0775', 'group': 'vector'})
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "group": 0,
-    "mode": "0755",
+    "group": 1002,
+    "mode": "0775",
     "path": "/var/lib/vector",
-    "state": "absent"
+    "state": "directory"
 }

changed: [vector-1.ru-central1.internal] => (item={'path': '/var/lib/vector', 'mode': '0775', 'group': 'vector'})

TASK [Get Vector package] *******************************************************************************************************************************************************************************************************************************
changed: [vector-0.ru-central1.internal]
changed: [vector-1.ru-central1.internal]

TASK [Unarchive Vector package to destination] **********************************************************************************************************************************************************************************************************
changed: [vector-0.ru-central1.internal]
changed: [vector-1.ru-central1.internal]

TASK [Set Vector config from template] ******************************************************************************************************************************************************************************************************************
--- before
+++ after: /home/sergey/.ansible/tmp/ansible-local-31037ybh6lm1l/tmpnzh1z2kj/vector.yaml.j2
@@ -0,0 +1,20 @@
+data_dir: "/var/lib/vector"
+
+api:
+  enabled: true
+  address: "127.0.0.1:8686"
+
+sources:
+  var_logs:
+    type: "file"
+    include:
+      - "/var/log/*.log"
+    ignore_older: 86400
+
+sinks:
+  clickhouse:
+    inputs:
+      - "var_logs"
+    type: "clickhouse"
+    endpoint: "http://clickhouse-0.ru-central1.internal:8123"
+    table: "los"
\ No newline at end of file

changed: [vector-0.ru-central1.internal]
--- before
+++ after: /home/sergey/.ansible/tmp/ansible-local-31037ybh6lm1l/tmpfctcj9pl/vector.yaml.j2
@@ -0,0 +1,20 @@
+data_dir: "/var/lib/vector"
+
+api:
+  enabled: true
+  address: "127.0.0.1:8686"
+
+sources:
+  var_logs:
+    type: "file"
+    include:
+      - "/var/log/*.log"
+    ignore_older: 86400
+
+sinks:
+  clickhouse:
+    inputs:
+      - "var_logs"
+    type: "clickhouse"
+    endpoint: "http://clickhouse-0.ru-central1.internal:8123"
+    table: "los"
\ No newline at end of file

changed: [vector-1.ru-central1.internal]

TASK [Copy Vector default unit in systemd (if changed - notify handler)] ********************************************************************************************************************************************************************************
changed: [vector-0.ru-central1.internal]
changed: [vector-1.ru-central1.internal]

TASK [Create a symbolic links for starting systemd unit and bin] ****************************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/etc/systemd/system/vector.service",
-    "state": "absent"
+    "state": "link"
 }

changed: [vector-0.ru-central1.internal] => (item={'src': '/lib/systemd/system/vector.service', 'dest': '/etc/systemd/system/vector.service'})
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/etc/systemd/system/vector.service",
-    "state": "absent"
+    "state": "link"
 }

changed: [vector-1.ru-central1.internal] => (item={'src': '/lib/systemd/system/vector.service', 'dest': '/etc/systemd/system/vector.service'})
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/usr/bin/vector",
-    "state": "absent"
+    "state": "link"
 }

changed: [vector-0.ru-central1.internal] => (item={'src': '/etc/vector/vector-x86_64-unknown-linux-musl/bin/vector', 'dest': '/usr/bin/vector'})
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/usr/bin/vector",
-    "state": "absent"
+    "state": "link"
 }

changed: [vector-1.ru-central1.internal] => (item={'src': '/etc/vector/vector-x86_64-unknown-linux-musl/bin/vector', 'dest': '/usr/bin/vector'})

RUNNING HANDLER [Restart service Vector, also issue daemon-reload to pick up config changes] ************************************************************************************************************************************************************
changed: [vector-1.ru-central1.internal]
changed: [vector-0.ru-central1.internal]

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
clickhouse-0.ru-central1.internal : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-0.ru-central1.internal : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-1.ru-central1.internal : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

```
clickhouse-0.ru-central1.internal : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-0.ru-central1.internal : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-1.ru-central1.internal : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

---

```
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] *******************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

TASK [Get clickhouse distrib noarch packages] ***********************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal] => (item=clickhouse-client)
ok: [clickhouse-0.ru-central1.internal] => (item=clickhouse-server)
failed: [clickhouse-0.ru-central1.internal] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.2.3.5-2.rpm", "elapsed": 1, "gid": 1001, "group": "sergey", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "sergey", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 223603115, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.2.3.5-2.noarch.rpm"}

TASK [Get clickhouse distrib x86_64 instead] ************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

TASK [Install clickhouse packages] **********************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

TASK [Set the default listen address] *******************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

TASK [Flush handlers] ***********************************************************************************************************************************************************************************************************************************

TASK [Create database] **********************************************************************************************************************************************************************************************************************************
ok: [clickhouse-0.ru-central1.internal]

PLAY [Install Vector] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal]
ok: [vector-1.ru-central1.internal]

TASK [Ensure group "vector" exists] *********************************************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal]
ok: [vector-1.ru-central1.internal]

TASK [Add the user 'vector' with a bash shell, appending the group 'vector' and groups for scraping] ****************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal]
ok: [vector-1.ru-central1.internal]

TASK [Create bin and data directory] ********************************************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal] => (item={'path': '/etc/vector', 'mode': '0755', 'group': 'root'})
ok: [vector-1.ru-central1.internal] => (item={'path': '/etc/vector', 'mode': '0755', 'group': 'root'})
ok: [vector-0.ru-central1.internal] => (item={'path': '/var/lib/vector', 'mode': '0775', 'group': 'vector'})
ok: [vector-1.ru-central1.internal] => (item={'path': '/var/lib/vector', 'mode': '0775', 'group': 'vector'})

TASK [Get Vector package] *******************************************************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal]
ok: [vector-1.ru-central1.internal]

TASK [Unarchive Vector package to destination] **********************************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal]
ok: [vector-1.ru-central1.internal]

TASK [Set Vector config from template] ******************************************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal]
ok: [vector-1.ru-central1.internal]

TASK [Copy Vector default unit in systemd (if changed - notify handler)] ********************************************************************************************************************************************************************************
ok: [vector-1.ru-central1.internal]
ok: [vector-0.ru-central1.internal]

TASK [Create a symbolic links for starting systemd unit and bin] ****************************************************************************************************************************************************************************************
ok: [vector-0.ru-central1.internal] => (item={'src': '/lib/systemd/system/vector.service', 'dest': '/etc/systemd/system/vector.service'})
ok: [vector-1.ru-central1.internal] => (item={'src': '/lib/systemd/system/vector.service', 'dest': '/etc/systemd/system/vector.service'})
ok: [vector-0.ru-central1.internal] => (item={'src': '/etc/vector/vector-x86_64-unknown-linux-musl/bin/vector', 'dest': '/usr/bin/vector'})
ok: [vector-1.ru-central1.internal] => (item={'src': '/etc/vector/vector-x86_64-unknown-linux-musl/bin/vector', 'dest': '/usr/bin/vector'})

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
clickhouse-0.ru-central1.internal : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-0.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-1.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

```
clickhouse-0.ru-central1.internal : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-0.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-1.ru-central1.internal : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook). Так же приложите скриншоты выполнения заданий №5-8

[playbook.md](playbook.md)

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

ok