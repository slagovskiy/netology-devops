
module "clickhouse" {
  source             = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id         = module.vpc_prod.network.id
  subnet_zones       = [var.clickhouse_params.zone]
  subnet_ids         = [module.vpc_prod.subnet[var.clickhouse_params.zone].id]
  instance_name      = var.clickhouse_params.instance_name
  instance_count     = var.clickhouse_params.count
  instance_cores     = var.clickhouse_params.instance_cores
  instance_memory    = var.clickhouse_params.instance_memory
  boot_disk_size     = var.clickhouse_params.boot_disk_size
  image_family       = var.clickhouse_params.image_family
  public_ip          = var.clickhouse_params.public_ip

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
    serial-port-enable = 1
  }
}

module "vectors" {
  source             = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id         = module.vpc_prod.network.id
  subnet_zones       = [var.vector_params.zone]
  subnet_ids         = [module.vpc_prod.subnet[var.vector_params.zone].id]
  instance_name      = var.vector_params.instance_name
  instance_count     = var.vector_params.count
  instance_cores     = var.vector_params.instance_cores
  instance_memory    = var.vector_params.instance_memory
  boot_disk_size     = var.vector_params.boot_disk_size
  image_family       = var.vector_params.image_family
  public_ip          = var.vector_params.public_ip

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
    serial-port-enable = 1
  }
}

module "lighthouse" {
  source             = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id         = module.vpc_prod.network.id
  subnet_zones       = [var.lighthouse_params.zone]
  subnet_ids         = [module.vpc_prod.subnet[var.lighthouse_params.zone].id]
  instance_name      = var.lighthouse_params.instance_name
  instance_count     = var.lighthouse_params.count
  instance_cores     = var.lighthouse_params.instance_cores
  instance_memory    = var.lighthouse_params.instance_memory
  boot_disk_size     = var.lighthouse_params.boot_disk_size
  image_family       = var.lighthouse_params.image_family
  public_ip          = var.lighthouse_params.public_ip

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
    serial-port-enable = 1
  }
}

data "template_file" "web_cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.web_packages)
  }
}