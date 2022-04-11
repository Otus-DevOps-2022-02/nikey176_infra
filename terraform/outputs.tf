output "external_ip_reddit-app-1" {
  value = yandex_compute_instance.app.0.network_interface.0.nat_ip_address
}
output "external_ip_reddit-app-2" {
  value = yandex_compute_instance.app.1.network_interface.0.nat_ip_address
}
output "zone_app" {
  value = yandex_compute_instance.app.0.zone
}
output "external_ip_load-balancer" {
  value = tolist(tolist(yandex_lb_network_load_balancer.reddit-app-lb.listener)[0].external_address_spec)[0].address
}