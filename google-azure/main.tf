##### Private Key for Web Server #####
resource "tls_private_key" "key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "null_resource" "save-key" {
  triggers {
    key = "${tls_private_key.key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}

##### Remote state in AzureRM #####
terraform {
  backend "azurerm" {
    resource_group_name  = "demo"
    storage_account_name = "demo"
    container_name       = "terraform-state"
    key                  = "demo.terraform.tfstate"
  }
}
