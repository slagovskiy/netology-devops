variable "name" {
  type        = string
  description = "VPC network&subnet name"
}

#variable "zone" {
#  type        = string
#  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
#}
#
#variable "cidr" {
#  type        = string
#  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
#}

variable "subnets" {
  type = list(object({
    zone = string,
    cidr = string
  }))
}