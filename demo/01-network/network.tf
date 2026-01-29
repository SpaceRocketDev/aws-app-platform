module "network" {
  source = "../../modules/network"

  network_config = local.network_config
}