module "acm_certs" {
  source     = "../../modules/acm"
  acm_config = local.acm_config
}
