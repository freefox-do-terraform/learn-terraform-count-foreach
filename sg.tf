resource "aws_security_group" "allow_all" {
  for_each = var.project

  name = "allow-all-${each.key}-${each.value.environment}"
  description = "Allow all inbound traffic"


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "vpc-d9f01dbf"
}
