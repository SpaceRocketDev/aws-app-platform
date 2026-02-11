variable "acm_config" {
  type = object({
    cert_arn = string
  })

  default = {
    cert_arn = "example.com"
  }
}
