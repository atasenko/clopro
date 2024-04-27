resource "yandex_compute_instance" "bastion" {
  name        = "bastion"

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.lemp_image_id
      size     = 5
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-1a.id
    nat       = true
  }

  metadata = {
    ssh-keys  = local.ssh-key
  }
}
