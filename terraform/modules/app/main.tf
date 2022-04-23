resource "yandex_compute_instance" "app" {
  name = "reddit-app-${var.environment}"
  labels = {
    tags = "reddit-app"
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
/* Закомментировано для ДЗ ansible-2
  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "../modules/app/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "../modules/app/files/deploy.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/Environment=/Environment=\"DATABASE_URL=${var.external_ip_address_db}:27017\"/' /etc/systemd/system/puma.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart puma.service"
    ]
  }
*/
}
