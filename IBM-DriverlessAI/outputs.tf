output sshcommand {
    description = "SSH command to connect to the instance"  
    value = "ssh root@${ibm_is_floating_ip.fip1.address}"
}

output "instance_ssh_private" {
    description = "Private SSH Key to connect to the instance"
    value = tls_private_key.ssh_key_keypair.private_key_pem
}

output "dai_url" {
    value = "http://${ibm_is_floating_ip.fip1.address}:12345"
}

