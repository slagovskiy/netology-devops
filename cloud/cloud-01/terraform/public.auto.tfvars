default_zone   = "ru-central1-a"
username       = "sergey"
ssh_public_key = "~/.ssh/id_ed25519.pub"
vm_packages    = ["vim", "mc", "traceroute"]

vpc_params = {
  name = "production"
  subnets = {
    public  = { zone = "ru-central1-a", cidr = "192.168.10.0/24" },
    private = { zone = "ru-central1-a", cidr = "192.168.20.0/24", route_nat = true },
  }
}

vm_params = {
  nat = {
    image_family    = "nat-instance-ubuntu"
    subnet          = "public"
    public_ip       = true
    ip              = "192.168.10.254"
    instance_cores  = 2
    instance_memory = 2
    boot_disk_size  = 30
  }
  public = {
    image_family    = "ubuntu-2004-lts"
    subnet          = "public"
    public_ip       = true
    instance_cores  = 2
    instance_memory = 2
    boot_disk_size  = 30
  }
  private = {
    image_family    = "ubuntu-2004-lts"
    subnet          = "private"
    public_ip       = false
    instance_cores  = 2
    instance_memory = 2
    boot_disk_size  = 30
  }
}