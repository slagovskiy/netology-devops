resource "local_file" "inventory" {
  content = templatefile(
    "${path.module}/inventory.tftpl", {
      clickhouse = { for i, v in module.clickhouse.external_ip_address : module.clickhouse.fqdn[i] => v }
      vectors    = { for i, v in module.vectors.external_ip_address : module.vectors.fqdn[i] => v }
      lighthouse    = { for i, v in module.lighthouse.external_ip_address : module.lighthouse.fqdn[i] => v }
    }
  )
  filename = "../playbook/inventory/prod.yml"
}