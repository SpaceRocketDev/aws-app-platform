# Availability zones used to spread subnets across the configured AZ count
data "aws_availability_zones" "az" {
  state = "available"
}
