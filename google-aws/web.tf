##### Google Provider #####
provider "google" {
  region  = "${var.region}"
}

##### Data Sources #####
data "google_compute_zones" "available" {}

data "google_compute_image" "base" {
  project = "ubuntu-os-cloud"
  family  = "ubuntu-1604-lts"
}

##### Script to Bootstrap Webserver ##### 
data "template_file" "web_server" {
  count = "${var.count}"

  template = <<EOF
${file("${path.module}/templates/common/provision.sh")}
${file("${path.module}/templates/webserver-provision.sh")}
EOF

  vars {
    username  = "${var.username}"
    node_name = "${var.app_name}-web-${count.index+1}"
    message   = "${var.message}"
    image_url = "${var.image_url}"
  }
}

##### Compute Resources #####
resource "google_compute_instance" "web_server" {
  count        = "${var.count}"
  name         = "${var.app_name}-web-${count.index+1}"
  machine_type = "n1-standard-1"
  zone         = "${data.google_compute_zones.available.names[0]}"

  tags = ["instance", "web"]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.base.self_link}"
      type  = "pd-ssd"
      size  = "60"
    }
  }

  network_interface {
    access_config = {}        # Public-facing IP
    network       = "default"
  }

  metadata {
    ssh-keys = "${var.username}:${trimspace(tls_private_key.key.public_key_openssh)} user@consul.io"
  }

  metadata_startup_script = "${element(data.template_file.web_server.*.rendered, count.index)}"

  service_account {
    scopes = ["compute-ro"]
  }
}

##### Security #####
resource "google_compute_firewall" "default" {
  name    = "${var.app_name}-web-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["instance"]
}

resource "google_compute_firewall" "allow-web" {
  name    = "${var.app_name}-allow-web-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

##### DNS #####

##### AWS Provider #####
provider "aws" {
  region = "${var.aws_region}"
}

data "aws_route53_zone" "default" {
  name = "hashicorp.fun."
}

resource "aws_route53_record" "web_server" {
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${var.app_name}.hashicorp.fun"
  type    = "A"
  ttl     = "5"
  records = ["${google_compute_instance.web_server.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

##### OUTPUTS #####
output "web_servers" {
  value = "${google_compute_instance.web_server.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "ssh" {
  value = "ssh -q -i ${path.module}/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no ${var.username}@${google_compute_instance.web_server.0.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "webapp" {
  value = "http://${aws_route53_record.web_server.name}"
}
