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

resource "aws_main_route_table_association" "ECS_MAIN_VPC_ROUT" {
  route_table_id = aws_route_table.Internet_Subnet_for_NAT.id
  vpc_id = aws_vpc.ECS_VPC.id
}

#ECS_SUBNETS ---FOR EVERY AVAILABILITY ZONE---

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

#INTERNET_NETWORK
resource "aws_subnet" "Internet_Subnet" {
  count = length(data.aws_availability_zones.aws-az.names)
  vpc_id = aws_vpc.ECS_VPC.id
  cidr_block = "10.10.10${count.index}.0/24"
  availability_zone = data.aws_availability_zones.aws-az.names[count.index]
  tags = {
    Name = "Internet_Facing_Subnet"
  }
}
resource "aws_internet_gateway" "ECS_Internet_Gateway" {
  vpc_id = aws_vpc.ECS_VPC.id
  tags = {
    Name = "ECS_Internet_Gateway_for_NAT"
  }
}

resource "aws_route_table" "Internet_Subnet_for_NAT" {
  vpc_id = aws_vpc.ECS_VPC.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ECS_Internet_Gateway.id
  }
}

resource "aws_route_table_association" "ECS_INET_Association" {
  count = length(aws_subnet.Internet_Subnet)
  route_table_id = aws_route_table.Internet_Subnet_for_NAT.id
  subnet_id = aws_subnet.Internet_Subnet[count.index].id
}

#NAT_NETWORK
resource "aws_eip" "ECS_NAT_EIP" {
  tags = {
    Name = "ECS_NAT"
  }
}

resource "aws_nat_gateway" "ECS_NAT" {
  allocation_id = aws_eip.ECS_NAT_EIP.id
  subnet_id = aws_subnet.Internet_Subnet[0].id
}

resource "aws_route_table" "ECS_NAT_Route" {
  vpc_id = aws_vpc.ECS_VPC.id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ECS_NAT.id
  }
}

#-----FOR EVERY SUBNET-----
resource "aws_route_table_association" "ECS_NAT_Associate" {
  count = length(aws_subnet.ESC_Subnet)
  route_table_id = aws_route_table.ECS_NAT_Route.id
  subnet_id = element(aws_subnet.ESC_Subnet.*.id, count.index )
}