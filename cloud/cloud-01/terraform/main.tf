data "yandex_compute_image" "images" {
  for_each = var.vm_params
  family   = each.value.image_family
}

data "template_file" "web_cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.vm_packages)
  }
}

resource "yandex_compute_instance" "vms" {
  for_each    = var.vm_params
  name        = each.key
  hostname    = each.key
  platform_id = "standard-v1"
  zone        = yandex_vpc_subnet.subnets[each.value.subnet].zone

  resources {
    cores  = each.value.instance_cores
    memory = each.value.instance_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.images[each.key].id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnets[each.value.subnet].id
    nat        = each.value.public_ip
    ip_address = each.value.ip == null ? null : each.value.ip
  }

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
    serial-port-enable = 1
  }
}