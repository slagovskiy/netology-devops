module "vpc_prod" {
  source  = "./vpc"
  name    = var.prod_env.vpc_name
  subnets = var.prod_env.subnets
}

resource "yandex_vpc_security_group" "vector" {
  name        = "vector"
  description = "vectors security group"
  network_id  = module.vpc_prod.network.id
}

resource "yandex_vpc_security_group" "clickhouse" {
  name        = "clickhouse"
  description = "clickhouse security group"
  network_id  = module.vpc_prod.network.id
}

resource "yandex_vpc_security_group_rule" "vector-logs" {
  security_group_binding = yandex_vpc_security_group.clickhouse.id
  direction              = "ingress"
  description            = "send logs from vector to clickhouse"
  security_group_id      = yandex_vpc_security_group.vector.id
  port                   = 8123
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "clickhouse-ssh" {
  security_group_binding = yandex_vpc_security_group.clickhouse.id
  direction              = "ingress"
  description            = "allow SSH access from Internet"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "TCP"
  port                   = 22
}

resource "yandex_vpc_security_group_rule" "hosts-ssh" {
  security_group_binding = yandex_vpc_security_group.vector.id
  direction              = "ingress"
  description            = "allow SSH access from Internet"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "TCP"
  port                   = 22
}

resource "yandex_vpc_security_group_rule" "clickhouse-egress" {
  security_group_binding = yandex_vpc_security_group.clickhouse.id
  direction              = "egress"
  description            = "outgoing requests"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}

resource "yandex_vpc_security_group_rule" "hosts-egress" {
  security_group_binding = yandex_vpc_security_group.vector.id
  direction              = "egress"
  description            = "outgoing requests"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}