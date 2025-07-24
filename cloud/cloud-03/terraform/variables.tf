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

variable "encrypted_bucket_params" {
  type = object({
    bucket_name = string
    bucket_acl  = string
  })
  description = "Encrypted Object Storage params"
}

variable "bucket_objects" {
  type = map(object({
    object_source = string
    object_acl    = string
  }))
}