variable "zone_a" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone_b" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "vpc_name_b" {
  type        = string
  default     = "develop_b"
  description = "VPC network & subnet name"
}

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "Name for vm web"
}
variable "vm_web_platform" {
  type        = string
  default     = "standard-v2"
  description = "Platform"
}

variable "vm_web_policy_preemptible" {
  type        = bool
  default     = true
  description = "If the instance is preemptible"
}
variable "vm_web_network_nat" {
  type        = bool
  default     = true
  description = "Provide a public address, for instance, to access the internet over NAT"
}

# variable "vm_web_metadata serial_port_enable" {
#   type    = string
#   default = "1"
# }

# variable "vm_web_metadata_ssh_keys" {
#   type    = string
#   default = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrN2UcKehwx9WssN1HAp/IUwMxlvrfLLXZuyrvqGgyr yc"
# }


variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "Name for vm db"
}
variable "vm_db_platform" {
  type        = string
  default     = "standard-v2"
  description = "Platform"
}

variable "vm_db_policy_preemptible" {
  type        = bool
  default     = true
  description = "If the instance is preemptible"
}
variable "vm_db_network_nat" {
  type        = bool
  default     = true
  description = "Provide a public address, for instance, to access the internet over NAT"
}

# variable "vm_db_metadata_serial_port_enable" {
#   type    = string
#   default = "1"
# }

# variable "vm_db_metadata_serial_ssh_keys" {
#   type    = string
#   default = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrN2UcKehwx9WssN1HAp/IUwMxlvrfLLXZuyrvqGgyr yc"
# }


# variable "vm_web_resources_codes" {
#   type    = number
#   default = 2
# }

# variable "vm_web_resources_memmory" {
#   type    = number
#   default = 1
# }

# variable "vm_web_resources_core_fraction" {
#   type    = number
#   default = 5
# }

# variable "vm_db_resources_codes" {
#   type    = number
#   default = 2
# }

# variable "vm_db_resources_memmory" {
#   type    = number
#   default = 1
# }

# variable "vm_db_resources_core_fraction" {
#   type    = number
#   default = 5
# }


variable "vm_resources" {
  type        = map(map(number))
  description = "Resources for VM"
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    },
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

  }
}

variable "vm_metadata" {
  type        = map(string)
  description = "Metadata map for VMs"
  default = {
    serial_port_enable = "1"
    ssh_keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrN2UcKehwx9WssN1HAp/IUwMxlvrfLLXZuyrvqGgyr yc"
  }
}


