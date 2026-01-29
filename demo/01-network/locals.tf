locals {
  env = var.env

  network_config = {
    account_id = data.aws_caller_identity.current.account_id
    project    = var.project
    aws_region = var.aws_region

    project_name = "${var.project}-${local.env}"

    # required by modules/network input type
    name_prefix = "${var.org}-${var.project}-${local.env}"

    az_num              = 3
    vpc_ip_block        = "172.27.72.0/22"
    subnet_cidr_private = "172.27.72.0/24"
    subnet_cidr_public  = "172.27.73.0/24"
    new_bits_private    = 2
    new_bits_public     = 2

    natgw_count = var.natgw_count

    # public_ips = {
    #   for ip in var.allowed_ips : "${ip}/32" => "Allowed IP"
    #   if !can(regex("/", ip))
    # }

    public_ips_v6 = {}
    app_ports     = [80, 443]

    common_tags = {
      Env       = local.env
      ManagedBy = "terraform"
      Project   = var.project
    }
  }
}
