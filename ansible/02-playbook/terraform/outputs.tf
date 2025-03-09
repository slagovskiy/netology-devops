resource "local_file" "inventory" {
  content = templatefile(
    "${path.module}/inventory.tftpl", {
      clickhouse = { for i, v in module.clickhouse-vm.external_ip_address : module.clickhouse-vm.fqdn[i] => v }
      vectors    = { for i, v in module.vector-vms.external_ip_address : module.vector-vms.fqdn[i] => v }
    }
  )
  filename = "../playbook/inventory/prod.yml"
}