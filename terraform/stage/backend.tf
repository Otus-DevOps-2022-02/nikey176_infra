terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "s3-nchernukha"
    region     = "ru-central1-a"
    key        = "terraform/stage/terraform.tfstate"
    access_key = "YCAJED-4xWpPFnaz_Gtu1QfW1"
    secret_key = "YCOpiOgrDfJLIhvNhtZC4KjxmpBo9MULTTMDEpeF"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
