###cloud vars


variable "cloud_id" {
  type        = string
  default     = "b1g10hm1l50eocmema3h"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gghlg0i9r4su8up17l"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}


###ssh vars

# variable "vms_ssh_root_key" {
#   type        = string
#   default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrN2UcKehwx9WssN1HAp/IUwMxlvrfLLXZuyrvqGgyr yc"
#   description = "ssh-keygen -t ed25519"
# }



