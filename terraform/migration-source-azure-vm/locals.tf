#region network interface

locals {
  ip_configuration_name        = "ip-configuration"
  private_ip_allocation_method = "static"
}

#endregion network interface

#region managed disk

locals {
  storage_os_disk_storage_account_type = "StandardSSD_LRS" # case-sensitive
  storage_os_disk_create_option        = "fromimage"
  storage_os_disk_os_type              = "linux"
}

#endregion managed disk

#region platform image - ubuntu

locals {
  platform_image_publisher = "Canonical"
  platform_image_offer     = "UbuntuServer"
  platform_image_sku       = "18.04-LTS"
  platform_image_version   = "latest"
}

#endregion platform image

#region public ip

locals {
  public_ip_sku               = "standard"
  public_ip_allocation_method = "Static"   # case-sensitive  
}

#endregion // public ip

#region network security group rules

locals {
  port_all   = "*"
  port_http  = "80"
  port_https = "443"
  port_ssh   = "22"
  port_mgn   = "1500"
}

locals {
  address_prefix_all = "*"
}

locals {
  protocol_any = "any"
  protocol_tcp = "tcp"
  protocol_udp = "udp"
}

locals {
  access_allow = "Allow" # case-sensitive
  access_deny  = "Deny"  # case-sensitive
}

locals {
  direction_inbound  = "Inbound"  # case-sensitive
  direction_outbound = "Outbound" # case-sensitive
}

#endregion network security group rules

#region wp and mariadb

locals {
  wp_database_name = "wordpress"
  wp_database_user = "wpdbuser"  
}

#endregion // wp and mariadb