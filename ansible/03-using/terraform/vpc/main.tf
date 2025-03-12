terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.13"
    }
  }
}

# Создаем облачную сеть
resource "yandex_vpc_network" "vpc" {
  name = var.name
}

# Создаем подсеть в указанной зоне
resource "yandex_vpc_subnet" "subnet" {
  for_each       = { for i in var.subnets : i.zone => i }
  name           = "${var.name}-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [each.value.cidr]
}