
# Домашнее задание к занятию 2. «Применение принципов IaaC в работе с виртуальными машинами»

#### Это задание для самостоятельной отработки навыков и не предполагает обратной связи от преподавателя. Его выполнение не влияет на завершение модуля. Но мы рекомендуем его выполнить, чтобы закрепить полученные знания. Все вопросы, возникающие в процессе выполнения заданий, пишите в учебный чат или в раздел "Вопросы по заданиям" в личном кабинете.
---
## Важно

**Перед началом работы над заданием изучите [Инструкцию по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**
Перед отправкой работы на проверку удаляйте неиспользуемые ресурсы.
Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
Подробные рекомендации [здесь](https://github.com/netology-code/virt-homeworks/blob/virt-11/r/README.md).

---

### Цели задания

1. Научиться создвать виртуальные машины в Virtualbox с помощью Vagrant.
2. Научиться базовому использованию packer в yandex cloud.

   
## Задача 1
Установите на личный Linux-компьютер или учебную **локальную** ВМ с Linux следующие сервисы(желательно ОС ubuntu 20.04):

- [VirtualBox](https://www.virtualbox.org/),
- [Vagrant](https://github.com/netology-code/devops-materials), рекомендуем версию 2.3.4
- [Packer](https://github.com/netology-code/devops-materials/blob/master/README.md) версии 1.9.х + плагин от Яндекс Облако по [инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/packer-quickstart)
- [уandex cloud cli](https://cloud.yandex.com/ru/docs/cli/quickstart) Так же инициализируйте профиль с помощью ```yc init``` .


Примечание: Облачная ВМ с Linux в данной задаче не подойдёт из-за ограничений облачного провайдера. У вас просто не установится virtualbox.

---

## Решение 1

```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant -v
Vagrant 2.4.3
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ yc -v
Yandex Cloud CLI 0.141.0 linux/amd64
```

---

## Задача 2

1. Убедитесь, что у вас есть ssh ключ в ОС или создайте его с помощью команды ```ssh-keygen -t ed25519```
2. Создайте виртуальную машину Virtualbox с помощью Vagrant и  [Vagrantfile](https://github.com/netology-code/virtd-homeworks/blob/shvirtd-1/05-virt-02-iaac/src/Vagrantfile) в директории src.
3. Зайдите внутрь ВМ и убедитесь, что Docker установлен с помощью команды:
```
docker version && docker compose version
```

3. Если Vagrant выдаёт ошибку (блокировка трафика):
```
URL: ["https://vagrantcloud.com/bento/ubuntu-20.04"]     
Error: The requested URL returned error: 404:
```

Выполните следующие действия:

- Скачайте с [сайта](https://app.vagrantup.com/bento/boxes/ubuntu-20.04) файл-образ "bento/ubuntu-20.04".
- Добавьте его в список образов Vagrant: "vagrant box add bento/ubuntu-20.04 <путь к файлу>".

**Важно:**    
- Если ваша хостовая рабочая станция - это windows ОС, то у вас могут возникнуть проблемы со вложенной виртуализацией. Ознакомиться со cпособами решения можно [по ссылке](https://www.comss.ru/page.php?id=7726).

- Если вы устанавливали hyper-v или docker desktop, то  все равно может возникать ошибка:  
`Stderr: VBoxManage: error: AMD-V VT-X is not available (VERR_SVM_NO_SVM)`   
 Попробуйте в этом случае выполнить в Windows от администратора команду `bcdedit /set hypervisorlaunchtype off` и перезагрузиться.

- Если ваша рабочая станция в меру различных факторов не может запустить вложенную виртуализацию - допускается неполное выполнение(до ошибки запуска ВМ)

---

## Решение 2


```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant box list
bento/ubuntu-20.04 (virtualbox, 202407.23.0, (amd64))
```

Vagrantfile:

```
ISO = "bento/ubuntu-20.04"
NET = "192.168.56."
DOMAIN = ".netology"
HOST_PREFIX = "server"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "shell",  inline: <<-EOF
        export DEBIAN_FRONTEND=noninteractive
        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository to Apt sources:
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo apt-get install -y htop 
      EOF
    end
  end
end
```

```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202407.23.0' is up to date...
==> server1.netology: Setting the name of the VM: server1.netology
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: 
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology: 
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
    server1.netology: The guest additions on this VM do not match the installed version of
    server1.netology: VirtualBox! In most cases this is fine, but in rare cases it can
    server1.netology: prevent things such as shared folders from working properly. If you see
    server1.netology: shared folder errors, please make sure the guest additions within the
    server1.netology: virtual machine match the version of VirtualBox you have installed on
    server1.netology: your host and reload your VM.
    server1.netology: 
    server1.netology: Guest Additions Version: 7.0.18
    server1.netology: VirtualBox Version: 7.1
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /home/sergey/Work/netology-devops/virtualization/IaaC => /vagrant
==> server1.netology: Running provisioner: shell...
    server1.netology: Running: inline script
    server1.netology: Hit:1 http://us.archive.ubuntu.com/ubuntu focal InRelease
    server1.netology: Get:2 http://us.archive.ubuntu.com/ubuntu focal-updates InRelease [128 kB]
    server1.netology: Get:3 http://us.archive.ubuntu.com/ubuntu focal-backports InRelease [128 kB]
    server1.netology: Get:4 http://us.archive.ubuntu.com/ubuntu focal-security InRelease [128 kB]
    server1.netology: Get:5 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [3,744 kB]
    server1.netology: Get:6 http://us.archive.ubuntu.com/ubuntu focal-updates/main Translation-en [572 kB]
    server1.netology: Get:7 http://us.archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [3,504 kB]
    server1.netology: Get:8 http://us.archive.ubuntu.com/ubuntu focal-updates/restricted Translation-en [490 kB]
    server1.netology: Get:9 http://us.archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [1,254 kB]
    server1.netology: Get:10 http://us.archive.ubuntu.com/ubuntu focal-updates/universe Translation-en [301 kB]
    server1.netology: Get:11 http://us.archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [27.9 kB]
    server1.netology: Get:12 http://us.archive.ubuntu.com/ubuntu focal-updates/multiverse Translation-en [7,968 B]
    server1.netology: Get:13 http://us.archive.ubuntu.com/ubuntu focal-security/main amd64 Packages [3,366 kB]
    server1.netology: Get:14 http://us.archive.ubuntu.com/ubuntu focal-security/main Translation-en [493 kB]
    server1.netology: Get:15 http://us.archive.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [3,357 kB]
    server1.netology: Get:16 http://us.archive.ubuntu.com/ubuntu focal-security/restricted Translation-en [470 kB]
    server1.netology: Get:17 http://us.archive.ubuntu.com/ubuntu focal-security/universe amd64 Packages [1,031 kB]
    server1.netology: Get:18 http://us.archive.ubuntu.com/ubuntu focal-security/universe Translation-en [218 kB]
    server1.netology: Get:19 http://us.archive.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [24.8 kB]
    server1.netology: Fetched 19.2 MB in 9s (2,225 kB/s)
    server1.netology: Reading package lists...
    server1.netology: Reading package lists...
    server1.netology: Building dependency tree...
    server1.netology: Reading state information...
    server1.netology: gnupg is already the newest version (2.2.19-3ubuntu2.2).
    server1.netology: The following packages will be upgraded:
    server1.netology:   ca-certificates curl libcurl4
    server1.netology: 3 upgraded, 0 newly installed, 0 to remove and 64 not upgraded.
    server1.netology: Need to get 555 kB of archives.
    server1.netology: After this operation, 11.3 kB of additional disk space will be used.
    server1.netology: Get:1 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 ca-certificates all 20240203~20.04.1 [159 kB]
    server1.netology: Get:2 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 curl amd64 7.68.0-1ubuntu2.25 [162 kB]
    server1.netology: Get:3 http://us.archive.ubuntu.com/ubuntu focal-updates/main amd64 libcurl4 amd64 7.68.0-1ubuntu2.25 [235 kB]
    server1.netology: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    server1.netology: Fetched 555 kB in 2s (280 kB/s)
(Reading database ... 41439 files and directories currently installed.)
    server1.netology: Preparing to unpack .../ca-certificates_20240203~20.04.1_all.deb ...
    server1.netology: Unpacking ca-certificates (20240203~20.04.1) over (20230311ubuntu0.20.04.1) ...
    server1.netology: Preparing to unpack .../curl_7.68.0-1ubuntu2.25_amd64.deb ...
    server1.netology: Unpacking curl (7.68.0-1ubuntu2.25) over (7.68.0-1ubuntu2.22) ...
    server1.netology: Preparing to unpack .../libcurl4_7.68.0-1ubuntu2.25_amd64.deb ...
    server1.netology: Unpacking libcurl4:amd64 (7.68.0-1ubuntu2.25) over (7.68.0-1ubuntu2.22) ...
    server1.netology: Setting up ca-certificates (20240203~20.04.1) ...
    server1.netology: Updating certificates in /etc/ssl/certs...
    server1.netology: rehash: warning: skipping ca-certificates.crt,it does not contain exactly one certificate or CRL
    server1.netology: 14 added, 5 removed; done.
    server1.netology: Setting up libcurl4:amd64 (7.68.0-1ubuntu2.25) ...
    server1.netology: Setting up curl (7.68.0-1ubuntu2.25) ...
    server1.netology: Processing triggers for man-db (2.9.1-1) ...
    server1.netology: Processing triggers for libc-bin (2.31-0ubuntu9.16) ...
    server1.netology: Processing triggers for ca-certificates (20240203~20.04.1) ...
    server1.netology: Updating certificates in /etc/ssl/certs...
    server1.netology: 0 added, 0 removed; done.
    server1.netology: Running hooks in /etc/ca-certificates/update.d...
    server1.netology: done.
    server1.netology: Get:1 https://download.docker.com/linux/ubuntu focal InRelease [57.7 kB]
    server1.netology: Hit:2 http://us.archive.ubuntu.com/ubuntu focal InRelease
    server1.netology: Hit:3 http://us.archive.ubuntu.com/ubuntu focal-updates InRelease
    server1.netology: Get:4 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages [54.3 kB]
    server1.netology: Hit:5 http://us.archive.ubuntu.com/ubuntu focal-backports InRelease
    server1.netology: Hit:6 http://us.archive.ubuntu.com/ubuntu focal-security InRelease
    server1.netology: Fetched 112 kB in 1s (94.6 kB/s)
    server1.netology: Reading package lists...
    server1.netology: Reading package lists...
    server1.netology: Building dependency tree...
    server1.netology: Reading state information...
    server1.netology: The following additional packages will be installed:
    server1.netology:   docker-ce-rootless-extras pigz slirp4netns
    server1.netology: Suggested packages:
    server1.netology:   aufs-tools cgroupfs-mount | cgroup-lite
    server1.netology: The following NEW packages will be installed:
    server1.netology:   containerd.io docker-buildx-plugin docker-ce docker-ce-cli
    server1.netology:   docker-ce-rootless-extras docker-compose-plugin pigz slirp4netns
    server1.netology: 0 upgraded, 8 newly installed, 0 to remove and 64 not upgraded.
    server1.netology: Need to get 124 MB of archives.
    server1.netology: After this operation, 447 MB of additional disk space will be used.
    server1.netology: Get:1 https://download.docker.com/linux/ubuntu focal/stable amd64 containerd.io amd64 1.7.25-1 [29.6 MB]
    server1.netology: Get:2 http://us.archive.ubuntu.com/ubuntu focal/universe amd64 pigz amd64 2.4-1 [57.4 kB]
    server1.netology: Get:3 http://us.archive.ubuntu.com/ubuntu focal/universe amd64 slirp4netns amd64 0.4.3-1 [74.3 kB]
    server1.netology: Get:4 https://download.docker.com/linux/ubuntu focal/stable amd64 docker-buildx-plugin amd64 0.19.3-1~ubuntu.20.04~focal [30.7 MB]
    server1.netology: Get:5 https://download.docker.com/linux/ubuntu focal/stable amd64 docker-ce-cli amd64 5:27.5.0-1~ubuntu.20.04~focal [15.2 MB]
    server1.netology: Get:6 https://download.docker.com/linux/ubuntu focal/stable amd64 docker-ce amd64 5:27.5.0-1~ubuntu.20.04~focal [26.1 MB]
    server1.netology: Get:7 https://download.docker.com/linux/ubuntu focal/stable amd64 docker-ce-rootless-extras amd64 5:27.5.0-1~ubuntu.20.04~focal [9,598 kB]
    server1.netology: Get:8 https://download.docker.com/linux/ubuntu focal/stable amd64 docker-compose-plugin amd64 2.32.4-1~ubuntu.20.04~focal [12.8 MB]
    server1.netology: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    server1.netology: Fetched 124 MB in 13s (9,545 kB/s)
    server1.netology: Selecting previously unselected package pigz.
(Reading database ... 41448 files and directories currently installed.)
    server1.netology: Preparing to unpack .../0-pigz_2.4-1_amd64.deb ...
    server1.netology: Unpacking pigz (2.4-1) ...
    server1.netology: Selecting previously unselected package containerd.io.
    server1.netology: Preparing to unpack .../1-containerd.io_1.7.25-1_amd64.deb ...
    server1.netology: Unpacking containerd.io (1.7.25-1) ...
    server1.netology: Selecting previously unselected package docker-buildx-plugin.
    server1.netology: Preparing to unpack .../2-docker-buildx-plugin_0.19.3-1~ubuntu.20.04~focal_amd64.deb ...
    server1.netology: Unpacking docker-buildx-plugin (0.19.3-1~ubuntu.20.04~focal) ...
    server1.netology: Selecting previously unselected package docker-ce-cli.
    server1.netology: Preparing to unpack .../3-docker-ce-cli_5%3a27.5.0-1~ubuntu.20.04~focal_amd64.deb ...
    server1.netology: Unpacking docker-ce-cli (5:27.5.0-1~ubuntu.20.04~focal) ...
    server1.netology: Selecting previously unselected package docker-ce.
    server1.netology: Preparing to unpack .../4-docker-ce_5%3a27.5.0-1~ubuntu.20.04~focal_amd64.deb ...
    server1.netology: Unpacking docker-ce (5:27.5.0-1~ubuntu.20.04~focal) ...
    server1.netology: Selecting previously unselected package docker-ce-rootless-extras.
    server1.netology: Preparing to unpack .../5-docker-ce-rootless-extras_5%3a27.5.0-1~ubuntu.20.04~focal_amd64.deb ...
    server1.netology: Unpacking docker-ce-rootless-extras (5:27.5.0-1~ubuntu.20.04~focal) ...
    server1.netology: Selecting previously unselected package docker-compose-plugin.
    server1.netology: Preparing to unpack .../6-docker-compose-plugin_2.32.4-1~ubuntu.20.04~focal_amd64.deb ...
    server1.netology: Unpacking docker-compose-plugin (2.32.4-1~ubuntu.20.04~focal) ...
    server1.netology: Selecting previously unselected package slirp4netns.
    server1.netology: Preparing to unpack .../7-slirp4netns_0.4.3-1_amd64.deb ...
    server1.netology: Unpacking slirp4netns (0.4.3-1) ...
    server1.netology: Setting up slirp4netns (0.4.3-1) ...
    server1.netology: Setting up docker-buildx-plugin (0.19.3-1~ubuntu.20.04~focal) ...
    server1.netology: Setting up containerd.io (1.7.25-1) ...
    server1.netology: Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
    server1.netology: Setting up docker-compose-plugin (2.32.4-1~ubuntu.20.04~focal) ...
    server1.netology: Setting up docker-ce-cli (5:27.5.0-1~ubuntu.20.04~focal) ...
    server1.netology: Setting up pigz (2.4-1) ...
    server1.netology: Setting up docker-ce-rootless-extras (5:27.5.0-1~ubuntu.20.04~focal) ...
    server1.netology: Setting up docker-ce (5:27.5.0-1~ubuntu.20.04~focal) ...
    server1.netology: Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /lib/systemd/system/docker.service.
    server1.netology: Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /lib/systemd/system/docker.socket.
    server1.netology: Processing triggers for man-db (2.9.1-1) ...
    server1.netology: Processing triggers for systemd (245.4-4ubuntu3.23) ...
    server1.netology: Reading package lists...
    server1.netology: Building dependency tree...
    server1.netology: Reading state information...
    server1.netology: htop is already the newest version (2.2.0-2build1).
    server1.netology: 0 upgraded, 0 newly installed, 0 to remove and 64 not upgraded.
```

```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant status
Current machine states:

server1.netology          running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

```

```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant ssh
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-189-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun 19 Jan 2025 07:55:14 AM UTC

  System load:           0.59
  Usage of /:            13.7% of 30.34GB
  Memory usage:          26%
  Swap usage:            0%
  Processes:             153
  Users logged in:       0
  IPv4 address for eth0: 10.0.2.15
  IPv6 address for eth0: fd00::a00:27ff:fecb:1a1d


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

Use of this system is acceptance of the OS vendor EULA and License Agreements.


vagrant@server1:~$ docker -v
Docker version 27.5.0, build a187fa5


vagrant@server1:~$ docker compose version
Docker Compose version v2.32.4
```

```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant destroy
    server1.netology: Are you sure you want to destroy the 'server1.netology' VM? [y/N] y
==> server1.netology: Forcing shutdown of VM...
==> server1.netology: Destroying VM and associated drives...


sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ vagrant status
Current machine states:

server1.netology          not created (virtualbox)

The environment has not yet been created. Run `vagrant up` to
create the environment. If a machine is not created, only the
default provider will be shown. So if a provider is not listed,
then the machine is not created for that environment.
```

---

## Задача 3

1. Отредактируйте файл    [mydebian.json.pkr.hcl](https://github.com/netology-code/virtd-homeworks/blob/shvirtd-1/05-virt-02-iaac/src/mydebian.json.pkr.hcl)  или [mydebian.jsonl](https://github.com/netology-code/virtd-homeworks/blob/shvirtd-1/05-virt-02-iaac/src/mydebian.json) в директории src (packer умеет и в json, и в hcl форматы):
   - добавьте в скрипт установку docker. Возьмите скрипт установки для debian из  [документации](https://docs.docker.com/engine/install/debian/)  к docker, 
   - дополнительно установите в данном образе htop и tmux.(не забудьте про ключ автоматического подтверждения установки для apt)
3. Найдите свой образ в web консоли yandex_cloud
4. Необязательное задание(*): найдите в документации yandex cloud как найти свой образ с помощью утилиты командной строки "yc cli".
5. Создайте новую ВМ (минимальные параметры) в облаке, используя данный образ.
6. Подключитесь по ssh и убедитесь в наличии установленного docker.
7. Удалите ВМ и образ.
8. **ВНИМАНИЕ!** Никогда не выкладываете oauth token от облака в git-репозиторий! Утечка секретного токена может привести к финансовым потерям. После выполнения задания обязательно удалите секретные данные из файла mydebian.json и mydebian.json.pkr.hcl. (замените содержимое токена на  "ххххх")
9. В качестве ответа на задание  загрузите результирующий файл в ваш ЛК.

---

## Решение 2


yc

```
sergey@netology-vm-01:~$ yc init
Welcome! This command will take you through the configuration process.
Pick desired action:
 [1] Re-initialize this profile 'default' with new settings 
 [2] Create a new profile
Please enter your numeric choice: 1
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.
 Please enter OAuth token: y0__***************************************
You have one cloud available: 'cloud-slagovskiy' (id = b1g10hm1l50eocmema3h). It is going to be used by default.
Please choose folder to use:
 [1] default (id = b1gghlg0i9r4su8up17l)
 [2] Create a new folder
Please enter your numeric choice: 1
Your current folder has been set to 'default' (id = b1gghlg0i9r4su8up17l).
Do you want to configure a default Compute zone? [Y/n] y
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-d
 [4] Don't set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.


sergey@netology-vm-01:~$ yc compute image list
+----+------+--------+-------------+--------+
| ID | NAME | FAMILY | PRODUCT IDS | STATUS |
+----+------+--------+-------------+--------+
+----+------+--------+-------------+--------+


sergey@netology-vm-01:~$ yc vpc network create --name net --labels name=netology --description "Netology net"
id: enp8jtc65nj1ipr90t5v
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-01-19T06:48:03Z"
name: net
description: Netology net
labels:
  name: netology
default_security_group_id: enpo13787mp4ueln0ji2



sergey@netology-vm-01:~$ yc vpc subnet create --name subnet-a --zone ru-central1-a --range 10.1.0.0/24 --network-name net --description "subnet a"
id: e9b3bkqr6l4pf7qumc52
folder_id: b1gghlg0i9r4su8up17l
created_at: "2025-01-19T06:53:11Z"
name: subnet-a
description: subnet a
network_id: enp8jtc65nj1ipr90t5v
zone_id: ru-central1-a
v4_cidr_blocks:
  - 10.1.0.0/24

```

config.pkr.hcl

```
packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}
```

```

sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ packer init config.pkr.hcl 

Installed plugin github.com/hashicorp/yandex v1.1.3 in "/home/sergey/.config/packer/plugins/github.com/hashicorp/yandex/packer-plugin-yandex_v1.1.3_x5.0_linux_amd64"
```


debian.json


```
{
    "builders": [
        {
            "type": "yandex",
            "token": "y0__********************************",
            "folder_id": "b1gghlg0i9r4su8up17l",
            "zone": "ru-central1-a",
            "image_name": "debian-11-docker",
            "image_description": "netology custom debian with docker",
            "source_image_family": "debian-11",
            "subnet_id": "e9b3bkqr6l4pf7qumc52",
            "use_ipv4_nat": true,
            "disk_type": "network-hdd",
            "ssh_username": "debian"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "inline": [
                "sudo apt-get update",
                "sudo apt-get install curl wget htop tmux -y",
                "sudo wget https://get.docker.com/ -O install_docker.sh && bash install_docker.sh",
                "docker -v && docker compose version"
            ]
        }
    ]
}
```

yc


```
sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ packer build debian.json 
yandex: output will be in this color.

==> yandex: Creating temporary RSA SSH key for instance...
==> yandex: Using as source image: fd82aveluqj5jnfumtsj (name: "debian-11-v20250106", family: "debian-11")
==> yandex: Use provided subnet id e9b3bkqr6l4pf7qumc52
==> yandex: Creating disk...
==> yandex: Creating instance...
==> yandex: Waiting for instance with id fhmchde1mlrjfm1l6uvh to become active...
    yandex: Detected instance IP: 158.160.55.250
==> yandex: Using SSH communicator to connect: 158.160.55.250
==> yandex: Waiting for SSH to become available...
==> yandex: Connected to SSH!
==> yandex: Provisioning with shell script: /tmp/packer-shell2917134426
    yandex: Get:1 http://mirror.yandex.ru/debian bullseye InRelease [116 kB]
    yandex: Get:2 http://mirror.yandex.ru/debian bullseye-updates InRelease [44.1 kB]
    yandex: Get:3 http://mirror.yandex.ru/debian bullseye-backports InRelease [49.0 kB]
    yandex: Get:4 http://security.debian.org bullseye-security InRelease [27.2 kB]
    yandex: Get:5 http://mirror.yandex.ru/debian bullseye/main Sources [8,500 kB]
    yandex: Get:6 http://mirror.yandex.ru/debian bullseye/main amd64 Packages [8,066 kB]
    yandex: Get:7 http://mirror.yandex.ru/debian bullseye/main Translation-en [6,235 kB]
    yandex: Get:8 http://mirror.yandex.ru/debian bullseye/main all Contents (deb) [31.3 MB]
    yandex: Get:9 http://security.debian.org bullseye-security/main Sources [226 kB]
    yandex: Get:10 http://security.debian.org bullseye-security/main amd64 Packages [334 kB]
    yandex: Get:11 http://security.debian.org bullseye-security/main Translation-en [216 kB]
    yandex: Get:12 http://mirror.yandex.ru/debian bullseye/main amd64 Contents (deb) [10.3 MB]
    yandex: Get:13 http://mirror.yandex.ru/debian bullseye-updates/main Sources [7,908 B]
    yandex: Get:14 http://mirror.yandex.ru/debian bullseye-updates/main amd64 Packages [18.8 kB]
    yandex: Get:15 http://mirror.yandex.ru/debian bullseye-updates/main Translation-en [10.9 kB]
    yandex: Get:16 http://mirror.yandex.ru/debian bullseye-updates/main all Contents (deb) [27.3 kB]
    yandex: Get:17 http://mirror.yandex.ru/debian bullseye-updates/main amd64 Contents (deb) [88.3 kB]
    yandex: Get:18 http://mirror.yandex.ru/debian bullseye-backports/main Sources [376 kB]
    yandex: Get:19 http://mirror.yandex.ru/debian bullseye-backports/main amd64 Packages [403 kB]
    yandex: Get:20 http://mirror.yandex.ru/debian bullseye-backports/main Translation-en [344 kB]
    yandex: Get:21 http://mirror.yandex.ru/debian bullseye-backports/main all Contents (deb) [4,672 kB]
    yandex: Get:22 http://mirror.yandex.ru/debian bullseye-backports/main amd64 Contents (deb) [1,133 kB]
    yandex: Fetched 72.5 MB in 10s (7,352 kB/s)
    yandex: Reading package lists...
    yandex: Reading package lists...
    yandex: Building dependency tree...
    yandex: Reading state information...
    yandex: htop is already the newest version (3.0.5-7).
    yandex: wget is already the newest version (1.21-1+deb11u1).
    yandex: wget set to manually installed.
    yandex: curl is already the newest version (7.74.0-1.3+deb11u14).
    yandex: The following additional packages will be installed:
    yandex:   libevent-2.1-7 libutempter0
    yandex: The following NEW packages will be installed:
    yandex:   libevent-2.1-7 libutempter0 tmux
    yandex: 0 upgraded, 3 newly installed, 0 to remove and 2 not upgraded.
    yandex: Need to get 560 kB of archives.
    yandex: After this operation, 1,362 kB of additional disk space will be used.
    yandex: Get:1 http://mirror.yandex.ru/debian bullseye/main amd64 libevent-2.1-7 amd64 2.1.12-stable-1 [188 kB]
    yandex: Get:2 http://mirror.yandex.ru/debian bullseye/main amd64 libutempter0 amd64 1.2.1-2 [8,960 B]
    yandex: Get:3 http://mirror.yandex.ru/debian bullseye/main amd64 tmux amd64 3.1c-1+deb11u1 [363 kB]
==> yandex: debconf: unable to initialize frontend: Dialog
==> yandex: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
==> yandex: debconf: falling back to frontend: Readline
==> yandex: debconf: unable to initialize frontend: Readline
==> yandex: debconf: (This frontend requires a controlling tty.)
==> yandex: debconf: falling back to frontend: Teletype
==> yandex: dpkg-preconfigure: unable to re-open stdin:
    yandex: Fetched 560 kB in 0s (5,385 kB/s)
    yandex: Selecting previously unselected package libevent-2.1-7:amd64.
    yandex: (Reading database ... 34368 files and directories currently installed.)
    yandex: Preparing to unpack .../libevent-2.1-7_2.1.12-stable-1_amd64.deb ...
    yandex: Unpacking libevent-2.1-7:amd64 (2.1.12-stable-1) ...
    yandex: Selecting previously unselected package libutempter0:amd64.
    yandex: Preparing to unpack .../libutempter0_1.2.1-2_amd64.deb ...
    yandex: Unpacking libutempter0:amd64 (1.2.1-2) ...
    yandex: Selecting previously unselected package tmux.
    yandex: Preparing to unpack .../tmux_3.1c-1+deb11u1_amd64.deb ...
    yandex: Unpacking tmux (3.1c-1+deb11u1) ...
    yandex: Setting up libevent-2.1-7:amd64 (2.1.12-stable-1) ...
    yandex: Setting up libutempter0:amd64 (1.2.1-2) ...
    yandex: Setting up tmux (3.1c-1+deb11u1) ...
    yandex: Processing triggers for libc-bin (2.31-13+deb11u11) ...
==> yandex: --2025-01-19 07:26:53--  https://get.docker.com/
==> yandex: Resolving get.docker.com (get.docker.com)... 3.161.82.96, 3.161.82.126, 3.161.82.21, ...
==> yandex: Connecting to get.docker.com (get.docker.com)|3.161.82.96|:443... connected.
==> yandex: HTTP request sent, awaiting response... 200 OK
==> yandex: Length: 22592 (22K) [text/plain]
==> yandex: Saving to: ‘install_docker.sh’
==> yandex:
==> yandex:      0K .......... .......... ..                              100% 6.60M=0.003s
==> yandex:
==> yandex: 2025-01-19 07:26:53 (6.60 MB/s) - ‘install_docker.sh’ saved [22592/22592]
==> yandex:
    yandex: # Executing docker install script, commit: 4c94a56999e10efcf48c5b8e3f6afea464f9108e
==> yandex: + sudo -E sh -c 'apt-get -qq update >/dev/null'
==> yandex: + sudo -E sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -qq install ca-certificates curl >/dev/null'
==> yandex: + sudo -E sh -c 'install -m 0755 -d /etc/apt/keyrings'
==> yandex: + sudo -E sh -c 'curl -fsSL "https://download.docker.com/linux/debian/gpg" -o /etc/apt/keyrings/docker.asc'
==> yandex: + sudo -E sh -c 'chmod a+r /etc/apt/keyrings/docker.asc'
==> yandex: + sudo -E sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list'
==> yandex: + sudo -E sh -c 'apt-get -qq update >/dev/null'
==> yandex: + sudo -E sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -qq install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin >/dev/null'
==> yandex: + sudo -E sh -c 'docker version'
    yandex: Client: Docker Engine - Community
    yandex:  Version:           27.5.0
    yandex:  API version:       1.47
    yandex:  Go version:        go1.22.10
    yandex:  Git commit:        a187fa5
    yandex:  Built:             Mon Jan 13 15:25:08 2025
    yandex:  OS/Arch:           linux/amd64
    yandex:  Context:           default
    yandex:
    yandex: Server: Docker Engine - Community
    yandex:  Engine:
    yandex:   Version:          27.5.0
    yandex:   API version:      1.47 (minimum version 1.24)
    yandex:   Go version:       go1.22.10
    yandex:   Git commit:       38b84dc
    yandex:   Built:            Mon Jan 13 15:25:08 2025
    yandex:   OS/Arch:          linux/amd64
    yandex:   Experimental:     false
    yandex:  containerd:
    yandex:   Version:          1.7.25
    yandex:   GitCommit:        bcc810d6b9066471b0b6fa75f557a15a1cbf31bb
    yandex:  runc:
    yandex:   Version:          1.2.4
    yandex:   GitCommit:        v1.2.4-0-g6c52b3f
    yandex:  docker-init:
    yandex:   Version:          0.19.0
    yandex:   GitCommit:        de40ad0
    yandex:
    yandex: ================================================================================
    yandex:
    yandex: To run Docker as a non-privileged user, consider setting up the
    yandex: Docker daemon in rootless mode for your user:
    yandex:
    yandex:     dockerd-rootless-setuptool.sh install
    yandex:
    yandex: Visit https://docs.docker.com/go/rootless/ to learn about rootless mode.
    yandex:
    yandex:
    yandex: To run the Docker daemon as a fully privileged service, but granting non-root
    yandex: users access, refer to https://docs.docker.com/go/daemon-access/
    yandex:
    yandex: WARNING: Access to the remote API on a privileged Docker daemon is equivalent
    yandex:          to root access on the host. Refer to the 'Docker daemon attack surface'
    yandex:          documentation for details: https://docs.docker.com/go/attack-surface/
    yandex:
    yandex: ================================================================================
    yandex:
    yandex: Docker version 27.5.0, build a187fa5
    yandex: Docker Compose version v2.32.4
==> yandex: Stopping instance...
==> yandex: Deleting instance...
    yandex: Instance has been deleted!
==> yandex: Creating image: debian-11-docker
==> yandex: Waiting for image to complete...
==> yandex: Success image create...
==> yandex: Destroying boot disk...
    yandex: Disk has been deleted!
Build 'yandex' finished after 3 minutes 6 seconds.

==> Wait completed after 3 minutes 6 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: debian-11-docker (id: fd8n3usot2fhunnh1e9n) with family name 



sergey@netology-vm-01:~/Work/netology-devops/virtualization/IaaC$ yc compute image list
+----------------------+------------------+--------+----------------------+--------+
|          ID          |       NAME       | FAMILY |     PRODUCT IDS      | STATUS |
+----------------------+------------------+--------+----------------------+--------+
| fd8n3usot2fhunnh1e9n | debian-11-docker |        | f2eg9b7205ltslc5johj | READY  |
+----------------------+------------------+--------+----------------------+--------+

```




---
