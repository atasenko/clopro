resource "yandex_vpc_network" "netology" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  network_id     = yandex_vpc_network.netology.id
  zone           = var.default_zone
  v4_cidr_blocks = var.public_cidr
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  network_id     = yandex_vpc_network.netology.id
  zone           = var.default_zone
  v4_cidr_blocks = var.private_cidr
  route_table_id = yandex_vpc_route_table.private.id
  depends_on     = [yandex_vpc_route_table.private]
}

resource "yandex_vpc_route_table" "private" {
  name       = "private_gateway"
  network_id = yandex_vpc_network.netology.id
  depends_on = [yandex_compute_instance.public]

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.public.network_interface[0].ip_address
  }
}

resource "yandex_compute_instance" "public" {
  name        = "public"

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    ssh-keys  = local.ssh-key
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "private" {
  name        = "private"

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.private.image_id
      size     = 10
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.private.id

  }

  metadata = {
    ssh-keys  = local.ssh-key
    serial-port-enable = 1
  }
}
