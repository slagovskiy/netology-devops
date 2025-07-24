default_zone = "ru-central1-a"
encrypted_bucket_params = {
  bucket_name = "slagovskiy-20250724"
  bucket_acl  = "public-read"
}
bucket_objects = {
  "image.jpg" = {
    object_source = "files/image.jpg"
    object_acl    = "public-read"
  }
}