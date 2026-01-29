locals {
  name_prefix = "${var.org}-${var.project}-${var.env}"

  common_tags = merge(
    {
      Org     = var.org
      Project = var.project
      Env     = var.env
    },
    var.extra_tags
  )
}
