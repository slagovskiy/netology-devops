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

variable "ssh_public_key" {
  type        = string
  description = "Location of SSH public key."
}

variable "vm_packages" {
  type        = list(string)
  description = "Packages to install on vm creates"
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

variable "lamp_group_params" {
  type = object({
    group_name = string
    image_family    = string
    instance_cores  = number
    instance_memory = number
    group_size = number
    max_unavailable = number
    max_expansion = number
  })
  description = "LAMP VM params"
}

locals {
  image_source = "http://${yandex_storage_bucket.slagovskiy.bucket_domain_name}/image.jpg"
}

variable "storage_params" {
  type = object({
    bucket_name = string
    bucket_acl = string
    object_key = string
    object_source = string
    object_acl = string
  })
  description = "Object Storage and Object params for LAMP vms"
}