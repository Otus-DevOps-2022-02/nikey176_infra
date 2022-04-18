terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "nch-terraform"
    region     = "ru-central1-a"
    key        = "terraform/stage/terraform.tfstate"
    access_key = "YCAJEAvkzOMzOpdWezxD7r3OW"
    secret_key = "YCNjnT8kbLiRAbEsDmgcdh-qgNeSDh6iS_O9y8q6"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
