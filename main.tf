data "aws_availability_zones" "aws-az" {
  state = "available"
}

#VPC

resource "aws_vpc" "ECS_VPC" {
  cidr_block = var.VPC_CIDR
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag}VPC"
  }
}

#SUBNETS

resource "aws_subnet" "ESC_Subnet" {
  count = length(data.aws_availability_zones.aws-az.names)
  vpc_id = aws_vpc.ECS_VPC.id
  cidr_block = cidrsubnet(aws_vpc.ECS_VPC.cidr_block,8 ,count.index + 1 )
  availability_zone = data.aws_availability_zones.aws-az.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.tag}_Subnet_${count.index + 1}"
  }

}