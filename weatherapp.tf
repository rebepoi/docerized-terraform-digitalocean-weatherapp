# Set the variable value in *.tfvars file
variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "weatherapp_key"
  public_key = "${file(var.pub_key)}"
}

# Create a web server
resource "digitalocean_droplet" "weatherapp" {
  image  = "docker-16-04"
  name   = "weatherapp"
  region = "ams2"
  size   = "512mb"
#  user_data = "#cloud-config\n\nssh_authorized_keys:\n — \"${file("${var.pub_key}")}\"\n"
  ssh_keys = [
  "${var.ssh_fingerprint}"
  ]

  connection {
   user = "root"
   type = "ssh"
   private_key = "${file(var.pvt_key)}"
   timeout = "2m"
  }
  provisioner "remote-exec" {
  inline = [
   "export PATH=$PATH:/usr/bin",
   "service docker start",
   "cd ~/",
   "git clone https://github.com/rebepoi/forecast",
   "curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
   "chmod +x /usr/local/bin/docker-compose",
   "cd forecast",
   "docker build -t forecast_front ./frontend/",
   "docker build -t forecast_back ./backend/",
   "docker swarm init --advertise-addr ${digitalocean_droplet.weatherapp.ipv4_address}",
#   "docker stack deploy -c docker-compose.yml weatherapp"
    "docker-compose up -d"
  ]
 }
}
output "ip_v4_address_public" {
    value = "${digitalocean_droplet.weatherapp.ipv4_address}"
}
