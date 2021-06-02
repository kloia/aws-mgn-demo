# region resource group

variable "rg_name" {
  default = "workload-migration-demo-rg"
}

variable "rg_location" {
  default = "West Europe"
}

# endregion // resource group

# region vnet

variable "vnet_name" {
  default = "workload-migration-demo-vnet"
}

variable "vnet_address_prefix" {
  default = "10.0.0.0/16"
}

variable "public_subnet_name" {
  default = "workload-migration-demo-public-subnet-001"
}
variable "public_subnet_address_prefix" {
  default = "10.0.0.0/24"
}


# endregion // vnet

# region network interface

variable "network_interface_name" {
  default = "workload-migration-demo-network-interface"
}

# endregion // network interface

# region virtual machine

variable "vm_name" {
  default = "workload-migration-demo-vm"
}

variable "vm_username" {
  default = "localadmin"
}

variable "vm_password" {
  default = "Password1234!"
}

variable "vm_size" {
  default = "standard_d2s_v3"
}

# endregion // virtual machine

#region managed disk

variable "managed_disk_name" {
  default = "azureblr-demo-managed-disk"
}

variable "managed_disk_size_gb" {
  default = 30
}

#endregion // managed disk

#region public ip

variable "public_ip_name" {
  default = "workload-migration-demo-public-ip"
}

variable "public_ip_fqdn" {
  default = "migration-workload-demo-fqdn"
}

#endregion // public ip

#region network security group

variable "nsg_name" {
  default = "workload-migration-demo-nsg"
}

#endregion // network security group