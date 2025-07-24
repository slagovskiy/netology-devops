# Домашнее задание к занятию «Безопасность в облачных провайдерах»

Используя конфигурации, выполненные в рамках предыдущих домашних заданий, нужно добавить возможность шифрования бакета.

---
## Задание 1. Yandex Cloud   

1. С помощью ключа в KMS необходимо зашифровать содержимое бакета:

 - создать ключ в KMS;
 - с помощью ключа зашифровать содержимое бакета, созданного ранее.

## Решение

terraform apply

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-03/terraform$ terraform apply -auto-approve

...
...
...


Plan: 8 to add, 0 to change, 0 to destroy.
yandex_kms_symmetric_key.netology-key: Creating...
yandex_iam_service_account.storage-sa: Creating...
yandex_kms_symmetric_key.netology-key: Creation complete after 1s [id=abjbmcm2batbh66qr6l4]
yandex_iam_service_account.storage-sa: Creation complete after 2s [id=ajev0ahj0ml2otcu59mk]
yandex_resourcemanager_cloud_iam_member.bucket-kms-encrypter: Creating...
yandex_resourcemanager_cloud_iam_member.bucket-kms-decrypter: Creating...
yandex_iam_service_account_static_access_key.storage-sa: Creating...
yandex_resourcemanager_cloud_iam_member.bucket-editor: Creating...
yandex_iam_service_account_static_access_key.storage-sa: Creation complete after 2s [id=aje4icbbmb8rm6p349hp]
yandex_resourcemanager_cloud_iam_member.bucket-kms-decrypter: Creation complete after 3s [id=b1g10hm1l50eocmema3h/kms.keys.decrypter/serviceAccount:ajev0ahj0ml2otcu59mk]
yandex_resourcemanager_cloud_iam_member.bucket-kms-encrypter: Creation complete after 6s [id=b1g10hm1l50eocmema3h/kms.keys.encrypter/serviceAccount:ajev0ahj0ml2otcu59mk]
yandex_resourcemanager_cloud_iam_member.bucket-editor: Creation complete after 9s [id=b1g10hm1l50eocmema3h/storage.editor/serviceAccount:ajev0ahj0ml2otcu59mk]
yandex_storage_bucket.encrypted: Creating...
yandex_storage_bucket.encrypted: Still creating... [10s elapsed]
yandex_storage_bucket.encrypted: Creation complete after 10s [id=slagovskiy-20250724]
yandex_storage_object.download-objects["image.jpg"]: Creating...
yandex_storage_object.download-objects["image.jpg"]: Creation complete after 1s [id=image.jpg]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

ключ шифрования

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-03/terraform$ yc kms symmetric-key list

+----------------------+-------------------------+----------------------+-------------------+---------------------+--------+
|          ID          |          NAME           |  PRIMARY VERSION ID  | DEFAULT ALGORITHM |     CREATED AT      | STATUS |
+----------------------+-------------------------+----------------------+-------------------+---------------------+--------+
| abjbmcm2batbh66qr6l4 | netology-encryption-key | abje6q9nncj2vtm24iii | AES_256           | 2025-07-24 11:53:12 | ACTIVE |
+----------------------+-------------------------+----------------------+-------------------+---------------------+--------+
```

backet

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-03/terraform$ yc storage buckets list

+---------------------+----------------------+------------+-----------------------+---------------------+
|        NAME         |      FOLDER ID       |  MAX SIZE  | DEFAULT STORAGE CLASS |     CREATED AT      |
+---------------------+----------------------+------------+-----------------------+---------------------+
| slagovskiy-20250724 | b1gghlg0i9r4su8up17l | 1073741824 | STANDARD              | 2025-07-24 11:53:23 |
+---------------------+----------------------+------------+-----------------------+---------------------+
```

Файл зашифрован: server_side_encryption: aws:kms

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-03/terraform$ yc storage s3api head-object --bucket slagovskiy-20250724 --key image.jpg

etag: '"ee4f650bae97c04a809a631ca13dbd13"'
request_id: 7ebe724689fa119b
accept_ranges: bytes
content_length: "144112"
content_type: application/octet-stream
last_modified_at: "2025-07-24T11:53:33Z"
server_side_encryption: aws:kms
sse_kms_key_id: abjbmcm2batbh66qr6l4
```

При попытке получить файл без аргументов получаем отказ

```
sergey@netology-01:~/Work/netology-devops/cloud/cloud-03/terraform$ curl https://storage.yandexcloud.net/slagovskiy-20250724/image.jpg
```
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Error>
    <Code>AccessDenied</Code>
    <Message>Access Denied</Message>
    <Resource>/slagovskiy-20250724/image.jpg</Resource>
    <RequestId>34914e07b36d51df</RequestId>
</Error>
```