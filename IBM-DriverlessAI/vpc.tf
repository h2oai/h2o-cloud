
resource ibm_is_vpc "vpc" {
  name = "${var.basename}-vpc"
}

# allow all incoming network traffic on port 22

resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"   
                      
  tcp {
    port_min = 22
    port_max = 22
  }
}
resource "ibm_is_security_group_rule" "dai" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"                       
  tcp  {
    port_min = 12345
    port_max = 12345
  }
}
resource ibm_is_subnet "subnet1" {
  name = "${var.basename}-subnet1"
  vpc  = ibm_is_vpc.vpc.id
  zone = var.vpc_zone
  total_ipv4_address_count = 256
}

resource "ibm_is_volume" "cloud_storage" {
  name = "${var.basename}-cloud-storage"
  zone = var.vpc_zone
  capacity = var.storage_capacity
  profile = var.storage_profile
}


data ibm_is_image "ubuntu" {
  name = "ibm-ubuntu-18-04-3-minimal-ppc64le-4"
}

resource "ibm_is_ssh_key" "public_key" {
  name = "${var.basename}-public-key"
  public_key = tls_private_key.ssh_key_keypair.public_key_openssh
}

resource "tls_private_key" "ssh_key_keypair" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

resource ibm_is_instance "vsi1" {
  name    = "${var.basename}-vsi1"
  vpc     = ibm_is_vpc.vpc.id
  zone    = var.vpc_zone
  keys    = [ibm_is_ssh_key.public_key.id]
  image   = data.ibm_is_image.ubuntu.id
  profile = var.compute_profile
  volumes = [ibm_is_volume.cloud_storage.id]

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }  
}

resource ibm_is_floating_ip "fip1" {
  name   = "${var.basename}-fip1"
  target = ibm_is_instance.vsi1.primary_network_interface.0.id
}

resource "null_resource" "provisioners" {

  triggers = {    
    ip_address = ibm_is_floating_ip.fip1.address
  }
  
  provisioner "file" {
    source      = "scripts"
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.ssh_key_keypair.private_key_pem
    }
  }

  provisioner "file" {
    source      = "config.toml.sh"
    destination = "/tmp/config.toml"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.ssh_key_keypair.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [  
      "set -e",    
      "chmod +x /tmp/scripts*/*",     
      "/tmp/scripts/install_dai.sh",
      "/tmp/scripts/install_zlib_manual.sh",      
      "ppc64_cpu --smt=4",
      "systemctl start dai",
      "exit 0",
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.ssh_key_keypair.private_key_pem
    }
  }
}