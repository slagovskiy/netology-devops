output "instance_info" {
  value = [
    yandex_compute_instance.platform.name,
    yandex_compute_instance.platform.fqdn,
    yandex_compute_instance.platform.network_interface[0].nat_ip_address,
    yandex_compute_instance.platform2.name,
    yandex_compute_instance.platform2.fqdn,
    yandex_compute_instance.platform2.network_interface[0].nat_ip_address
  ]
}
