module "codepipeline" {
  source              = "../../../modules/codepipeline"
  codepipeline_config = local.codepipeline_config
}