resource "azurerm_resource_group" "workload_migration_demo_rg" {
  name     = "${var.rg_name}"
  location = "${var.rg_location}"
  tags = {
    environment = "testing"
  }
}


# Create virtual network with public and private subnets.
resource "azurerm_virtual_network" "workload_migration_demo_vnet" {
    name                = "${var.vnet_name}"
    address_space       = ["${var.vnet_address_prefix}"]
    location            = "${azurerm_resource_group.workload_migration_demo_rg.location}"
    resource_group_name = "${azurerm_resource_group.workload_migration_demo_rg.name}"

    tags = {
    environment = "testing"
  }
}

resource "azurerm_subnet" "workload_migration_demo_public_subnet" {
  name                      = "${var.public_subnet_name}"
  resource_group_name       = "${azurerm_resource_group.workload_migration_demo_rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.workload_migration_demo_vnet.name}"
  address_prefix            = "${var.public_subnet_address_prefix}"  
}

resource "azurerm_public_ip" "workload_migration_demo_public_ip" {
  # adds implicit dependency on the resource group
  resource_group_name = "${azurerm_resource_group.workload_migration_demo_rg.name}"
  location            = "${azurerm_resource_group.workload_migration_demo_rg.location}"

  name              = "${var.public_ip_name}"
  sku               = "${local.public_ip_sku}"
  allocation_method = "${local.public_ip_allocation_method}"
  domain_name_label = "${var.public_ip_fqdn}"
  tags = {
    environment = "testing"
  }
}

resource "azurerm_network_security_group" "workload_migration_demo_nsg" {
  # adds implicit dependency on the resource group
  resource_group_name = "${azurerm_resource_group.workload_migration_demo_rg.name}"
  location            = "${azurerm_resource_group.workload_migration_demo_rg.location}"

  name = "${var.nsg_name}"

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 300
    direction                  = "${local.direction_inbound}"
    access                     = "${local.access_allow}"
    protocol                   = "${local.protocol_tcp}"
    source_port_range          = "${local.port_all}"
    destination_port_range     = "${local.port_ssh}"
    source_address_prefix      = "${local.address_prefix_all}"
    destination_address_prefix = "*"
    # destination_address_prefix = "${var.default_subnet_address_prefix}"
  }

  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 310
    direction                  = "${local.direction_inbound}"
    access                     = "${local.access_allow}"
    protocol                   = "${local.protocol_tcp}"
    source_port_range          = "${local.port_all}"
    destination_port_range     = "${local.port_http}"
    source_address_prefix      = "${local.address_prefix_all}"
    destination_address_prefix = "${var.public_subnet_address_prefix}"
  }

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 320
    direction                  = "${local.direction_inbound}"
    access                     = "${local.access_allow}"
    protocol                   = "${local.protocol_tcp}"
    source_port_range          = "${local.port_all}"
    destination_port_range     = "${local.port_https}"
    source_address_prefix      = "${local.address_prefix_all}"
    destination_address_prefix = "${var.public_subnet_address_prefix}"
  }
  security_rule {
    name                       = "allow-mgn-inbound"
    priority                   = 330
    direction                  = "${local.direction_inbound}"
    access                     = "${local.access_allow}"
    protocol                   = "${local.protocol_tcp}"
    source_port_range          = "${local.port_all}"
    destination_port_range     = "${local.port_mgn}"
    source_address_prefix      = "${local.address_prefix_all}"
    destination_address_prefix = "${var.public_subnet_address_prefix}"
  }

}

resource "azurerm_network_interface" "workload_migration_demo_network_interface" {
  # adds implicit dependency on the resource group
  resource_group_name = "${azurerm_resource_group.workload_migration_demo_rg.name}"
  location            = "${azurerm_resource_group.workload_migration_demo_rg.location}"
  name = "${var.network_interface_name}"

  ip_configuration {
    name = "ip-configuration-1"

    # adds implicit dependency on the public ip
    public_ip_address_id = "${azurerm_public_ip.workload_migration_demo_public_ip.id}"

    # adds implicit dependency on the vnet resource (created via module)
    subnet_id                     = "${azurerm_subnet.workload_migration_demo_public_subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "testing"
  }
}

# Associate network security group with public subnet.
resource "azurerm_subnet_network_security_group_association" "public_subnet_assoc" {
  subnet_id                 = "${azurerm_subnet.workload_migration_demo_public_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.workload_migration_demo_nsg.id}"
}

resource "tls_private_key" "id_rsa" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "id_rsa" {
  content  = "${tls_private_key.id_rsa.private_key_pem}"
  filename = "./demo_rsa"

  provisioner "local-exec" {
    command = "chmod 700 ./demo_rsa"
  }
}

resource "azurerm_virtual_machine" "workload_migration_demo_vm" {
  # adds implicit dependency on the resource group
  resource_group_name = "${azurerm_resource_group.workload_migration_demo_rg.name}"
  location            = "${azurerm_resource_group.workload_migration_demo_rg.location}"

  name = "${var.vm_name}"

  network_interface_ids = [azurerm_network_interface.workload_migration_demo_network_interface.id]

  vm_size = "${var.vm_size}"

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.vm_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${tls_private_key.id_rsa.public_key_openssh}"
      path     = "/home/${var.vm_username}/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    publisher = "${local.platform_image_publisher}"
    offer     = "${local.platform_image_offer}"
    sku       = "${local.platform_image_sku}"
    version   = "${local.platform_image_version}"
  }

  storage_os_disk {
    name              = "${var.managed_disk_name}"
    create_option     = "${local.storage_os_disk_create_option}"
    managed_disk_type = "${local.storage_os_disk_storage_account_type}"
    os_type           = "${local.storage_os_disk_os_type}"
    disk_size_gb      = "${var.managed_disk_size_gb}"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  tags = {
    environment = "testing"
  }
}
