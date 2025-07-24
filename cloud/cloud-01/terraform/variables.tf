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
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "username" {
  description = "name of predefined user on VM"
  type        = string
}

variable "vpc_params" {
  description = "Production VPC environment variables"
  type = object({
    name = string
    subnets = map(object({
      zone      = string
      cidr      = string
      route_nat = optional(bool)
    }))
  })
}

variable "vm_params" {
  type = map(object({
    image_family    = string
    subnet          = string
    public_ip       = bool
    ip              = optional(string)
    instance_cores  = number
    instance_memory = number
    boot_disk_size  = number
  }))
  description = "VM params (key = instance name)"
}

variable "ssh_public_key" {
  type        = string
  description = "Location of SSH public key."
}

variable "vm_packages" {
  type        = list(string)
  description = "Packages to install on vm creates"
}