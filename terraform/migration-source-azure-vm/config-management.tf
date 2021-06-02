resource "null_resource" "installation_mariadb" {
  triggers = {
    ids = "${azurerm_virtual_machine.workload_migration_demo_vm.id}"
  }

  connection {
    host        = "${azurerm_public_ip.workload_migration_demo_public_ip.fqdn}"
    user        = "${var.vm_username}"
    type        = "ssh"
    private_key = "${tls_private_key.id_rsa.private_key_pem}"
  }

  provisioner "remote-exec" {
    script = "./scripts/mariadb-ubuntu.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mysql -u root -e \"CREATE DATABASE ${local.wp_database_name}\"",
      "sudo mysql -u root -e \"CREATE USER '${local.wp_database_user}'@'localhost'\"",
      "sudo mysql -u root -e \"GRANT ALL PRIVILEGES ON *.* TO '${local.wp_database_user}'@'localhost' WITH GRANT OPTION\"",

      "sudo systemctl restart mariadb",
    ]
  }
}

resource "null_resource" "installation_wp" {
  depends_on = ["null_resource.installation_mariadb"]

  triggers = {
    ids = "${azurerm_virtual_machine.workload_migration_demo_vm.id}"
  }

  connection {
    host        = "${azurerm_public_ip.workload_migration_demo_public_ip.ip_address}"
    user        = "${var.vm_username}"
    private_key = "${tls_private_key.id_rsa.private_key_pem}"
  }

  provisioner "remote-exec" {
    script = "./scripts/wp-ubuntu.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ${var.vm_username}:${var.vm_username} /var/www/html/",
      "cd /var/www/html/",
      "sudo -u ${var.vm_username} /usr/local/bin/wp core download --version=5.1.1",
      "sudo -u ${var.vm_username} /usr/local/bin/wp core config --dbname='${local.wp_database_name}' --dbuser='${local.wp_database_user}'",
      "sudo -u ${var.vm_username} rm -rf index.html",
    ]
  }
}
