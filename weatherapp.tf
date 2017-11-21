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
  name       = "weatherapp_key2"
  public_key = "${file(var.pub_key)}"
}

# Create a web server
resource "digitalocean_droplet" "weatherapp" {
  image  = "docker-16-04"
  name   = "weatherapp"
  region = "ams2"
  size   = "512mb"
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
   "sed -i -e 's/0.0.0.0:9000/${digitalocean_droplet.weatherapp.ipv4_address}:9000/g' ./frontend/webpack.config.js",
   "docker-compose up -d"
  ]
 }
}
output "ip_v4_address_public" {
    value = "${digitalocean_droplet.weatherapp.ipv4_address}"
}
