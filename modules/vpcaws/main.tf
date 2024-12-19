data "aws_availability_zones" "available" {

  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }

}

resource "aws_vpc" "main_vpc" {

  cidr_block = var.vpc_cidr
  
  enable_dns_hostnames = var.vpc_dns

  tags = {
    Name = "vpc_terraform"
  }

}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main_vpc.id #ya incluye el attachment al VPC

  tags = {
    Name = "igw_terraform"
  }
}

resource "aws_subnet" "publicsunet" {

  vpc_id            = aws_vpc.main_vpc.id

  count             = length(var.cidr_pub_subnets)

  cidr_block        = var.cidr_pub_subnets[count.index]
  #availability_zone = "${var.region}a" 

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {

               Name = "pubsunet_terraform"
  
  }

}

resource "aws_subnet" "privatesubnet" {

  vpc_id            = aws_vpc.main_vpc.id

  count             = length(var.cird_priv_subnets) # El numero de subredes privadas se obtendra de la lista de CIDRs

  cidr_block        = var.cird_priv_subnets[count.index]

  availability_zone = data.aws_availability_zones.available.names[1]
  #availability_zone = "${var.region}a" 

  tags = {

    Name = "privsubnet_terraform"
  
  }

}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    #nat_gateway_id = aws_nat_gateway.eks_nat_gw.id
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "routetable_private_terraform"
  }

  depends_on  = [ aws_subnet.privatesubnet ]
}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "routetable_public_terraform"
  }

  depends_on = [ aws_subnet.publicsunet ]

}

resource "aws_route_table_association" "topublic" {
  
  count = length(var.cidr_pub_subnets)

  subnet_id      = aws_subnet.publicsunet[count.index].id 
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "toprivate" {

  count = length(var.cird_priv_subnets)

  subnet_id      = aws_subnet.privatesubnet[count.index].id
  route_table_id = aws_route_table.private.id
}


output "pub_sunet_id" {

# Supongamos que es para 1 subnet

  value = aws_subnet.publicsunet.*.id
  
}

output "priv_subnet_id" {

  value = aws_subnet.privatesubnet.*.id
  
}

output "vpc_id" {

  value = aws_vpc.main_vpc.id
  
}





