# Домашнее задание к занятию 1 «Введение в Ansible»


1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.

---

```
$ ansible-playbook -i inventory/test.yml site.yml 

PLAY [Print os facts] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *****************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

---

2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.

---

```
$ ansible-playbook -i inventory/test.yml site.yml 

PLAY [Print os facts] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *****************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

---

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

---

```
$ docker compose up -d
obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 8/8
 ✔ ubuntu Pulled                                                                                                                                                                                                                                   56.8s 
   ✔ 423ae2b273f4 Pull complete                                                                                                                                                                                                                     6.9s 
   ✔ de83a2304fa1 Pull complete                                                                                                                                                                                                                     6.9s 
   ✔ f9a83bce3af0 Pull complete                                                                                                                                                                                                                     7.0s 
   ✔ b6b53be908de Pull complete                                                                                                                                                                                                                     7.0s 
   ✔ 7378af08dad3 Pull complete                                                                                                                                                                                                                    53.5s 
 ✔ centos Pulled                                                                                                                                                                                                                                   26.5s 
   ✔ 2d473b07cdd5 Pull complete                                                                                                                                                                                                                    22.6s 
[+] Running 3/3
 ✔ Network 01-base_default  Created                                                                                                                                                                                                                 0.1s 
 ✔ Container ubuntu         Started                                                                                                                                                                                                                 1.4s 
 ✔ Container centos7        Started                                                                                                                                                                                                                 1.4s 

$ docker ps
CONTAINER ID   IMAGE                      COMMAND       CREATED              STATUS              PORTS     NAMES
ea81a071d38f   pycontribs/ubuntu:latest   "/bin/bash"   About a minute ago   Up About a minute             ubuntu
32770c68986c   centos:centos7             "/bin/bash"   About a minute ago   Up About a minute             centos7

```

---

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

---
```
$ ansible-playbook -i inventory/prod.yml site.yml 

PLAY [Print os facts] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.

---
```
$ cat group_vars/{deb,el}/examp.yml
---
  some_fact: "deb default fact"
---
  some_fact: "el default fact"
```

---

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

---

```
$ ansible-playbook -i inventory/prod.yml site.yml 

PLAY [Print os facts] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
---

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

---

```
$ ansible-vault encrypt group_vars/{deb,el}/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
```

```
$ cat group_vars/{deb,el}/examp.yml
$ANSIBLE_VAULT;1.1;AES256
30343839343337633062623361323032316265383931316531643532666433343835386636623663
3464633134326164633839626562306361653531313163640a646436613765316365313833633066
30353764363063636336623862383731643138613332383231323835393737633562646262306263
3766346232353230370a373063336430363665373264306232633432663762633838373161393434
65393064396532393332356664643363376138336666326366353431376439333932396530613438
6635393537636439616463323736646634313736336339636264
$ANSIBLE_VAULT;1.1;AES256
64646662306230626239643761633138383438313063343238383434646237643932616563636133
3761353366356233323437646561376564373431373437640a323939633636646135383463643632
64396465643138666463653131336332393866353531613365363865663837623838613335653166
6530366133316264300a383535653661303237393966633533303437616534626266373865643639
36343561643764353239333734316633363339323762643039313031393032313038343663643630
3234353331656364326465393762623835653734613763636366

```

---

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

---

```
$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
---

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

---

```
$ ansible-doc -t connection -l
ansible.builtin.local          execute on controller                                                                                                                                                                                                
ansible.builtin.paramiko_ssh   Run tasks via Python SSH (paramiko)                                                                                                                                                                                  
ansible.builtin.psrp           Run tasks over Microsoft PowerShell Remoting Protocol                                                                                                                                                                
ansible.builtin.ssh            connect via SSH client binary                                                                                                                                                                                        
ansible.builtin.winrm          Run tasks over Microsoft's WinRM                                                                                                                                                                                     
ansible.netcommon.grpc         Provides a persistent connection using the gRPC protocol                                                                                                                                                             
ansible.netcommon.httpapi      Use httpapi to run command on network appliances                                                                                                                                                                     
ansible.netcommon.libssh       Run tasks using libssh for ssh connection                                                                                                                                                                            
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol                                                                                                                                                          
ansible.netcommon.network_cli  Use network_cli to run command on network appliances                                                                                                                                                                 
ansible.netcommon.persistent   Use a persistent unix socket for connection                                                                                                                                                                          
community.aws.aws_ssm          connect to EC2 instances via AWS Systems Manager                                                                                                                                                                     
community.docker.docker        Run tasks in docker containers                                                                                                                                                                                       
community.docker.docker_api    Run tasks in docker containers                                                                                                                                                                                       
community.docker.nsenter       execute on host running controller container                                                                                                                                                                         
community.general.chroot       Interact with local chroot                                                                                                                                                                                           
community.general.funcd        Use funcd to connect to target                                                                                                                                                                                       
community.general.incus        Run tasks in Incus instances via the Incus CLI                                                                                                                                                                       
community.general.iocage       Run tasks in iocage jails                                                                                                                                                                                            
community.general.jail         Run tasks in jails                                                                                                                                                                                                   
community.general.lxc          Run tasks in lxc containers via lxc python library                                                                                                                                                                   
community.general.lxd          Run tasks in LXD instances via `lxc' CLI                                                                                                                                                                             
community.general.qubes        Interact with an existing QubesOS AppVM                                                                                                                                                                              
community.general.saltstack    Allow ansible to piggyback on salt minions                                                                                                                                                                           
community.general.zone         Run tasks in a zone instance                                                                                                                                                                                         
community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt                                                                                                                                                                              
community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines                                                                                                                                                                           
community.okd.oc               Execute tasks in pods running on OpenShift                                                                                                                                                                           
community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools                                                                                                                                                                           
containers.podman.buildah      Interact with an existing buildah container                                                                                                                                                                          
containers.podman.podman       Interact with an existing podman container                                                                                                                                                                           
kubernetes.core.kubectl        Execute tasks in pods running on Kubernetes                  
```

---

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

---

```
$ cat inventory/prod.yml 
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

---

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

---

```
$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

---

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

ok

13. Предоставьте скриншоты результатов запуска команд.

ok