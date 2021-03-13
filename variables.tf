variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_id" {
  description = "default vpc id"
  type        = string
  default     = "vpc-d9f01dbf"
}

variable "project" {
  description = "Map of project names to configuration"
  type        = map(any)
  default = {
    project-alpha = {
      instances_per_subnet = 1,
      instance_type        = "t2.micro",
      environment          = "test"
    },
    project-beta = {
      instances_per_subnet = 2,
      instance_type        = "t2.micro",
      environment          = "stage"
    }
  }
}
