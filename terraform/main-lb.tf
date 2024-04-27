resource "yandex_compute_instance_group" "nginx_public" {
  name                = "nginx-public"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.ig-sa.id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory        = var.vm_resources.memory
      cores         = var.vm_resources.cores
      core_fraction = var.vm_resources.core_fraction
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.lemp_image_id
        size     = 5
      }
    }
    network_interface {
      network_id = yandex_vpc_network.netology.id
      subnet_ids = [yandex_vpc_subnet.public-1a.id]
    }
    metadata = {
      user-data = data.template_file.cloud-init.rendered
      ssh-keys = local.ssh-key
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone_1a]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

  load_balancer {
    target_group_name        = "nginx-lb-group"
  }
}

resource "yandex_lb_network_load_balancer" "lamp-lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.nginx_public.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}
