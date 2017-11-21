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
   "git clone -b with-swarm --single-branch https://github.com/rebepoi/forecast",
   "curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
   "chmod +x /usr/local/bin/docker-compose",
   "cd forecast",
   "docker swarm init --advertise-addr ${digitalocean_droplet.weatherapp.ipv4_address}",
   "docker service create --name registry -p 5000:5000 registry:2",
   "sed -i -e 's/0.0.0.0:9000/${digitalocean_droplet.weatherapp.ipv4_address}:9000/g' ./frontend/webpack.config.js",
   "docker-compose up -d",
   "docker-compose down --volumes",
   "docker-compose push",
   "docker stack deploy -c docker-compose.yml weatherapp",
   "docker run -it -d -p 81:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer"
  ]
 }
}
output "ip_v4_address_public" {
    value = "check forecast from: ${digitalocean_droplet.weatherapp.ipv4_address} and swarm from: ${digitalocean_droplet.weatherapp.ipv4_address}:81"
}
