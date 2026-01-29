variable "network_config" {
  type = object({
    base_domain         = string
    account_id          = string
    env                 = string
    project             = string
    aws_region          = string
    az_num              = number
    vpc_ip_block        = string
    subnet_cidr_private = string
    subnet_cidr_public  = string
    new_bits_private    = number
    new_bits_public     = number
    natgw_count         = string
    public_ips          = map(string)
    public_ips_v6       = map(string)
    app_ports           = list(number)
    common_tags         = map(string)
  })

  default = {
    base_domain         = "example.com"
    account_id          = ""
    env                 = "dev"
    project             = "default"
    aws_region          = "us-east-1"
    az_num              = 3
    vpc_ip_block        = "172.27.72.0/22"
    subnet_cidr_private = "172.27.72.0/24"
    subnet_cidr_public  = "172.27.73.0/24"
    new_bits_private    = 2
    new_bits_public     = 2
    natgw_count         = "none"
    public_ips          = { "0.0.0.0/0" = "Open" }
    public_ips_v6       = { "::/0" = "Open" }
    app_ports           = [80, 443]
    common_tags         = { Env = "dev", ManagedBy = "terraform", Project = "default" }
  }
}