# Pre-requirements
Docker CE or EE (I use CE) installed on system. Can be found from here: https://www.docker.com

# Instructions
Clone or download repository.

Create DigitalOcean API token, token must be read and write HOWTO: https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2

Copy paste token in modify-me.sh file to APITOKEN variable
´´´
APITOKEN="token goes here"
´´´

Navigate inside folder and run build, tag name is just for example.
´´´
docker build -t terra .
´´´

After build go inside freshly build image.
´´´
docker run -it --entrypoint=sh terra
´´´

Inside you have to initialize terraform settings.
´´´
terraform init
´´´

After init we will apply our settings and build everything inside DigitalOcean droplet. 
´´´
terraform apply
´´´

!! ON ERROR !! Some times there is error saying:
´´´
Error: Error applying plan:

1 error(s) occurred:

* digitalocean_droplet.weatherapp: 1 error(s) occurred:

* digitalocean_droplet.weatherapp: Error creating droplet: POST https://api.digitalocean.com/v2/droplets: 422 94:a1:7e:f4:4a:dd:d5:95:6c:e3:2a:ad:a9:a9:6c:39 are invalid key identifiers for Droplet creation.
´´´
That means that digitalocean has not updated your private key yet, just wait few seconds and run terraform apply again.

When redy terraform will output droplets ip and if you copy paste it in web browser, you can see current weather in Tampere :)
