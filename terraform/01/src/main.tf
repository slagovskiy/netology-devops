terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
  required_version = ">=1.8.4"
}
provider "docker" {}

#однострочный комментарий

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}


resource "docker_image" "nginx_img" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx_ctr" {
  image = docker_image.nginx_img.image_id
  name  = "hello_world"

  ports {
    internal = 80
    external = 9090
  }
}

