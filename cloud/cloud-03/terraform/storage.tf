resource "yandex_iam_service_account" "storage-sa" {
  name = "storage-service-account"
}

resource "yandex_resourcemanager_cloud_iam_member" "bucket-editor" {
  depends_on = [yandex_iam_service_account.storage-sa]
  cloud_id   = var.cloud_id
  role       = "storage.editor"
  member     = "serviceAccount:${yandex_iam_service_account.storage-sa.id}"
}

resource "yandex_resourcemanager_cloud_iam_member" "bucket-kms-encrypter" {
  depends_on = [yandex_iam_service_account.storage-sa]
  cloud_id   = var.cloud_id
  role       = "kms.keys.encrypter"
  member     = "serviceAccount:${yandex_iam_service_account.storage-sa.id}"
}

resource "yandex_resourcemanager_cloud_iam_member" "bucket-kms-decrypter" {
  depends_on = [yandex_iam_service_account.storage-sa]
  cloud_id   = var.cloud_id
  role       = "kms.keys.decrypter"
  member     = "serviceAccount:${yandex_iam_service_account.storage-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage-sa" {
  service_account_id = yandex_iam_service_account.storage-sa.id
  description        = "static access key for bucket"
}

resource "yandex_kms_symmetric_key" "netology-key" {
  name              = "netology-encryption-key"
  description       = "Key for encrypting bucket objects"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

resource "yandex_storage_bucket" "encrypted" {
  depends_on = [yandex_resourcemanager_cloud_iam_member.bucket-editor]
  access_key = yandex_iam_service_account_static_access_key.storage-sa.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage-sa.secret_key
  bucket     = var.encrypted_bucket_params.bucket_name
  max_size = 1073741824
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.netology-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "download-objects" {
  for_each   = var.bucket_objects
  access_key = yandex_iam_service_account_static_access_key.storage-sa.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage-sa.secret_key
  bucket     = yandex_storage_bucket.encrypted.bucket
  key        = each.key
  source     = each.value.object_source
  acl        = each.value.object_acl
  depends_on = [yandex_storage_bucket.encrypted]
}