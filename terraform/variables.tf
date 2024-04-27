variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "zone_1a" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone_1b" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "zone_1c" {
  type        = string
  default     = "ru-central1-c"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone_1d" {
  type        = string
  default     = "ru-central1-d"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "env_name" {
  type        = string
  default     = "netology"
}

variable "public_cidr_1a" {
  type        = list(string)
  default     = ["192.168.11.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "public_cidr_1b" {
  type        = list(string)
  default     = ["192.168.12.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "public_cidr_1c" {
  type        = list(string)
  default     = ["192.168.13.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "public_cidr_1d" {
  type        = list(string)
  default     = ["192.168.14.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "lemp_image_id" {
  type    = string
  default = "fd8jriet4mkponbhe021"
}

variable "image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_resources" {
  type = map(number)
  default  = { cores = "2", memory = "4", core_fraction = "5" }
}

variable "username" {
  default = "ubuntu"
}
