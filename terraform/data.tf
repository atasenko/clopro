data template_file "cloud-init" {
  template = file("cloud-init.yml")

  vars = {
    username = var.username
    ssh_key  = local.ssh-key
  }
}

data template_file "cloud-init-alb" {
  template = file("cloud-init-alb.yml")

  vars = {
    username = var.username
    ssh_key  = local.ssh-key
  }
}
