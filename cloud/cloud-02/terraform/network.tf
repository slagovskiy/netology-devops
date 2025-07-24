# Создаем VPC
resource "yandex_vpc_network" "vpc" {
  name = var.vpc_params.name
}

# Создаем подсети в VPC
resource "yandex_vpc_subnet" "subnets" {
  for_each       = var.vpc_params.subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [each.value.cidr]
}

resource "yandex_lb_network_load_balancer" "lb" {
  name = "network-lb"

  listener {
    name = "network-lb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}