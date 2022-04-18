variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable "subnet_id" {
  description = "Subnets for modules"
}
variable "environment" {
  description = "Environment"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "external_ip_address_db" {
  description = "DB address"
}
