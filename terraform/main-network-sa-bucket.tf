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

resource "yandex_kms_symmetric_key" "cat-key" {
  name              = "cat-symmetric-key"
  description       = "Key for cat safety"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" // equal to 1 year
}

resource "yandex_storage_bucket" "catpictures" {
  bucket     = "cats.tasenko.ru"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  acl        = "public-read"
  max_size   = 1073741824

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.cat-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  https {
    certificate_id = yandex_cm_certificate.cats-tasenko-ru.id
  }
}

resource "yandex_storage_object" "index-static" {
  bucket = yandex_storage_bucket.catpictures.bucket
  key    = "index.html"
  source = "../src/index.html"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  acl    = "public-read"
}

resource "yandex_storage_object" "error-static" {
  bucket = yandex_storage_bucket.catpictures.bucket
  key    = "error.html"
  source = "../src/error.html"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  acl    = "public-read"
}

resource "yandex_cm_certificate" "cats-tasenko-ru" {
  name    = "cats-tasenko-ru"
  domains = ["cats.tasenko.ru"]

  managed {
    challenge_type = "DNS_CNAME"
  }
}

resource "yandex_storage_object" "fridgecat" {
  bucket = yandex_storage_bucket.catpictures.bucket
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
