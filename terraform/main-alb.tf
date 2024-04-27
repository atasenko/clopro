resource "yandex_compute_instance_group" "nginx_public_alb" {
  name                = "nginx-public-alb"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.ig-sa.id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v2"
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
      security_group_ids = [yandex_vpc_security_group.alb-rules.id]
    }
    metadata = {
      user-data = data.template_file.cloud-init-alb.rendered
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

  application_load_balancer {
    target_group_name        = "nginx-alb-group"
  }
}

resource "yandex_alb_http_router" "cat-router" {
  name      = "my-cat-router"
}

resource "yandex_alb_virtual_host" "cat-virtual-host" {
  name      = "cat-virtual-host"
  http_router_id = yandex_alb_http_router.cat-router.id
  route {
    name = "cat-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.cat-backend-group.id
        timeout = "3s"
      }
    }
  }
}

resource "yandex_alb_backend_group" "cat-backend-group" {
  name      = "cat-backend-group"

  session_affinity {
    connection {
      source_ip = "true"
    }
  }

  http_backend {
    name = "cat-http-backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_compute_instance_group.nginx_public_alb.application_load_balancer[0].target_group_id]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "true"
  }
}

resource "yandex_alb_load_balancer" "cat-balancer" {
  name        = "app-cat-balancer"

  network_id  = yandex_vpc_network.netology.id

  allocation_policy {
    location {
      zone_id   = var.zone_1a
      subnet_id = yandex_vpc_subnet.public-1a.id
    }
  }

  security_group_ids = [yandex_vpc_security_group.alb-rules.id]

  listener {
    name = "cat-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.cat-router.id
      }
    }
  }

  log_options {
    discard_rule {
      http_code_intervals = ["HTTP_2XX"]
      discard_percent = 75
    }
  }
}

resource "yandex_vpc_security_group" "alb-rules" {
  name        = "alb-rules"
  network_id  = yandex_vpc_network.netology.id
  ingress {
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 30080
    to_port           = 30080
  }
  ingress {
    protocol          = "TCP"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 80
    to_port           = 80
  }
  ingress {
    protocol          = "TCP"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 443
    to_port           = 443
  }
  egress {
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}
