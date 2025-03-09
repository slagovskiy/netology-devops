###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "username" {
  type        = string
  description = "name of predefined user on VM"
  default     = "sergey"
}

variable "ssh_public_key" {
  type        = string
  description = "Location of SSH public key."
  default     = "/home/sergey/.ssh/yc.pub"
}

variable "web_packages" {
  type    = list(string)
  default = ["vim"]
}

variable "clickhouse_params" {
  type = object({
    count           = number
    instance_name   = string
    zone            = string
    image_family    = string
    public_ip       = bool
    instance_cores  = number
    instance_memory = number
    boot_disk_size  = number
  })
  description = "params for Clickhouse VM"
  default = {
    count           = 1
    instance_name   = "clickhouse"
    zone            = "ru-central1-a"
    image_family    = "centos-7"
    public_ip       = true
    instance_cores  = 2
    instance_memory = 4
    boot_disk_size  = 30
  }
}

variable "vector_params" {
  type = object({
    count           = number
    instance_name   = string
    zone            = string
    image_family    = string
    public_ip       = bool
    instance_cores  = number
    instance_memory = number
    boot_disk_size  = number
  })
  description = "params for VMs with Vector"
  default = {
    count           = 2
    instance_name   = "vector"
    zone            = "ru-central1-a"
    image_family    = "ubuntu-2004-lts"
    public_ip       = true
    instance_cores  = 2
    instance_memory = 2
    boot_disk_size  = 20
  }
}

variable "prod_env" {
  type = object({
    vpc_name = string
    subnets = list(object({
      zone = string
      cidr = string
    }))
  })
  description = "PROD environment variables"
  default = {
    vpc_name = "production"
    subnets = [
      { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    ]
  }
}