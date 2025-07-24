data "yandex_compute_image" "lamp" {
  family = var.lamp_group_params.image_family
}

data "template_file" "web_cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.vm_packages)
    image          = local.image_source
  }
}

resource "yandex_iam_service_account" "lamp-sa" {
  name        = "lamp-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

resource "yandex_resourcemanager_folder_iam_member" "lamp-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.lamp-sa.id}"
}

resource "yandex_compute_instance_group" "lamp" {
  depends_on         = [yandex_resourcemanager_folder_iam_member.lamp-editor]
  name               = var.lamp_group_params.group_name
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.lamp-sa.id
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = var.lamp_group_params.instance_memory
      cores  = var.lamp_group_params.instance_cores
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.lamp.id
      }
    }

    network_interface {
      network_id = yandex_vpc_network.vpc.id
      subnet_ids = [for key, value in yandex_vpc_subnet.subnets : value.id]
      #       values(yandex_vpc_subnet.subnets[*])
    }

    metadata = {
      user-data          = data.template_file.web_cloudinit.rendered
      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = var.lamp_group_params.group_size
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = var.lamp_group_params.max_unavailable
    max_expansion   = var.lamp_group_params.max_expansion
  }

  health_check {
    interval = 2
    timeout  = 1
    http_options {
      port = 80
      path = "/index.html"
    }
  }

  load_balancer {
    target_group_name        = "lamp-tg"
    target_group_description = "Целевая группа Network Load Balancer"
  }
}