output "lb_ip" {
  description = "External IP address of instances"
  value = [ for value in yandex_lb_network_load_balancer.lb.listener: tolist(value.external_address_spec)[0].address ]
}