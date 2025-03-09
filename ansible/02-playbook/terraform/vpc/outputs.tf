output "network" {
  value = yandex_vpc_network.vpc
}

output "subnet" {
  value = yandex_vpc_subnet.subnet
}

output "subnets" {
  value = [
    for k, v in yandex_vpc_subnet.subnet : {
      zone = v.zone
      id   = v.id
    }
  ]
}