# сервисный аккунт
resource "yandex_iam_service_account" "sa-diplom" {
  name = var.sa_name
}

# Права "editor"
resource "yandex_resourcemanager_folder_iam_member" "diplom-editor" {
  folder_id = var.folder_id
  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.sa-diplom.id}"
  depends_on = [ yandex_iam_service_account.sa-diplom ]
}

# Ключ для бакета
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-diplom.id
  description = "static access key"
}

# Применение ключа
resource "yandex_storage_bucket" "slagovskiy-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = var.bucket_name
  max_size = 1073741824 # 1 Gb
  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }
  force_destroy = true
  depends_on = [ yandex_resourcemanager_folder_iam_member.diplom-editor ]
}

# Сохранение в локальный файл
resource "local_file" "credfile" {
  content = <<EOT
[default]
aws_access_key_id = ${yandex_iam_service_account_static_access_key.sa-static-key.access_key}
aws_secret_access_key = ${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}
EOT
  filename = "../kuber/credfile.key"
}
