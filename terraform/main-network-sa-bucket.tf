resource "yandex_vpc_network" "netology" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "public-1a" {
  name           = "public-1a"
  network_id     = yandex_vpc_network.netology.id
  zone           = var.zone_1a
  v4_cidr_blocks = var.public_cidr_1a
}

resource "yandex_vpc_subnet" "public-1b" {
  name           = "public-1b"
  network_id     = yandex_vpc_network.netology.id
  zone           = var.zone_1b
  v4_cidr_blocks = var.public_cidr_1b
}

resource "yandex_vpc_subnet" "public-1c" {
  name           = "public-1c"
  network_id     = yandex_vpc_network.netology.id
  zone           = var.zone_1c
  v4_cidr_blocks = var.public_cidr_1c
}

resource "yandex_vpc_subnet" "public-1d" {
  name           = "public-1d"
  network_id     = yandex_vpc_network.netology.id
  zone           = var.zone_1d
  v4_cidr_blocks = var.public_cidr_1d
}

resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = "tf-test-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "catpictures" {
  bucket = "catpictures"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  acl    = "public-read"
}

resource "yandex_storage_object" "fridgecat" {
  bucket = "catpictures"
  key    = "cat.jpg"
  source = "../img/cat.jpg"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  tags = {
    cat_name = "Musya"
  }
  acl    = "public-read"
  object_lock_legal_hold_status = "OFF"
}

resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
}
