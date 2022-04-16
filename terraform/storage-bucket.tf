terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.73.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  folder_id                = var.folder_id
  zone                     = var.zone
  cloud_id                 = var.cloud_id
}

resource "yandex_storage_bucket" "nch-terraform" {
  access_key = "YCAJEAvkzOMzOpdWezxD7r3OW"
  secret_key = "YCNjnT8kbLiRAbEsDmgcdh-qgNeSDh6iS_O9y8q6"
  bucket     = "nch-terraform"
}
