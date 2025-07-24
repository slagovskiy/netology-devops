resource "yandex_iam_service_account" "storage-sa" {
  name = "storage-service-account"
}

resource "yandex_resourcemanager_cloud_iam_member" "bucket-editor" {
  depends_on = [ yandex_iam_service_account.storage-sa ]
  cloud_id = var.cloud_id
  role = "storage.editor"
  member = "serviceAccount:${yandex_iam_service_account.storage-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage-sa" {
  service_account_id = yandex_iam_service_account.storage-sa.id
  description = "static access key for bucket"
}

resource "yandex_storage_bucket" "slagovskiy" {
  depends_on = [yandex_resourcemanager_cloud_iam_member.bucket-editor]
  access_key = yandex_iam_service_account_static_access_key.storage-sa.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage-sa.secret_key
  bucket = var.storage_params.bucket_name
  max_size = 1073741824 # 1 Gb
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = false
  }
}

resource "yandex_storage_object" "object" {
  access_key = yandex_iam_service_account_static_access_key.storage-sa.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage-sa.secret_key
  bucket = yandex_storage_bucket.slagovskiy.bucket
  key = var.storage_params.object_key
  source = var.storage_params.object_source
  acl = var.storage_params.object_acl
  depends_on = [ yandex_storage_bucket.slagovskiy ]
}