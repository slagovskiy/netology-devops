resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_network" "develop_b" {
  name = var.vpc_name_b
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.zone_a
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = var.vpc_name_b
  zone           = var.zone_b
  network_id     = yandex_vpc_network.develop_b.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "platform" {
  name        = local.vm_web_name
  platform_id = var.vm_web_platform
  zone        = var.zone_a
  resources {
    cores         = var.vm_resources.web.cores
    memory        = var.vm_resources.web.memory
    core_fraction = var.vm_resources.web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_policy_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_network_nat
  }

  metadata = {
    serial-port-enable = var.vm_metadata.serial_port_enable
    ssh-keys           = var.vm_metadata.ssh_keys
  }
}


resource "yandex_compute_instance" "platform2" {
  name        = local.vm_db_name
  platform_id = var.vm_db_platform
  zone        = var.zone_b
  resources {
    cores         = var.vm_resources.db.cores
    memory        = var.vm_resources.db.memory
    core_fraction = var.vm_resources.db.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_policy_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = var.vm_db_network_nat
  }

  metadata = {
    serial-port-enable = var.vm_metadata.serial_port_enable
    ssh-keys           = var.vm_metadata.ssh_keys
  }
}
