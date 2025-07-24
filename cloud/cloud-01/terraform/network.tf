# Создаем VPC
resource "yandex_vpc_network" "vpc" {
  name = var.vpc_params.name
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat_route"
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.vm_params["nat"].ip
  }
}

# Создаем подсети в VPC
resource "yandex_vpc_subnet" "subnets" {
  for_each       = var.vpc_params.subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = each.value.route_nat == true ? yandex_vpc_route_table.nat_route.id : null
}