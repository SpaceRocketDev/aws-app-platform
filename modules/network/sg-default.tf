# Default Security Group for the VPC (kept empty to avoid accidental open rules)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}
