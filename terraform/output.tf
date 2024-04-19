output "hosts" {
  value = [
    for e in local.servers : {
      name = e.name,
      nat_ip   = e.network_interface[0].nat_ip_address
    }
  ]
}

locals {
  servers = flatten([
    yandex_compute_instance.public[*],
    yandex_compute_instance.private[*]
    ]
  )
}
