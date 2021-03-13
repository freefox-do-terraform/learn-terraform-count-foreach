terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
     profile  = "aws-devops"
     bucket   = "terraform-state-file-devops"
     region   = "ap-southeast-2"
     key      = "aws/foreach/terraform.tfstate"
  }
}

provider "aws" {
  profile = "aws-devops"
  region = var.aws_region
}

data "aws_subnet_ids" "default_vpc_subnet_ids" {
  vpc_id = var.vpc_id
}

resource "random_string" "lb_id" {
  length  = 4
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.4.0"

  for_each = var.project

  # Comply with ELB name restrictions 
  # https://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_CreateLoadBalancer.html
  name     = trimsuffix(substr(replace(join("-", ["lb", random_string.lb_id.result, each.key, each.value.environment]), "/[^a-zA-Z0-9-]/", ""), 0, 32), "-")
  internal = false

  security_groups = [aws_security_group.allow_all[each.key].id]
  subnets         = data.aws_subnet_ids.default_vpc_subnet_ids.ids 

  number_of_instances = length(module.ec2_instances[each.key].instance_ids)
  instances           = module.ec2_instances[each.key].instance_ids

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
  }
}

module "ec2_instances" {
  source = "./modules/aws-instance"

  for_each = var.project

  instance_count     = each.value.instances_per_subnet
  instance_type      = each.value.instance_type
  subnet_ids         = data.aws_subnet_ids.default_vpc_subnet_ids.ids
  security_group_ids = [aws_security_group.allow_all[each.key].id]

  project_name = each.key
  environment  = each.value.environment
}
