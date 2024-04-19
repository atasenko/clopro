locals {
  ssh-key = "${var.username}:${file("~/.ssh/id_ed25519.pub")}"
}
