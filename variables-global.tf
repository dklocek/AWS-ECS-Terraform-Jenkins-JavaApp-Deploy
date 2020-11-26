variable "Application_Name" {
  type = string
  default = "Application"
}
variable "aws_region" {
  type = string
  default = "eu-west-1"
}

variable "tag" {
  type = string
  default = "ECS_"
}

variable "VPC_CIDR" {
  type = string
  default = "10.10.0.0/16"
}

