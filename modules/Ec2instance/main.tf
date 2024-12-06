#resource "local_file" "state" {
#        content = "This configuration have ${var.change-state} state"
#        filename = "/root/${var.change-state}"
#}

data "aws_availability_zones" "available" {

  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }

}

data "aws_ami" "ubuntu" {

  most_recent = true             #la version mas reciente
  owners      = ["099720109477"] #owner of the ami

  #        filter {
  #               name = "name"
  #               values = ["amazon/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240927"]
  #       }

}

resource "aws_vpc" "main_vpc" {

  cidr_block = var.vpc_cidr

  provider = {
    
    aws = aws.case1
    aws = aws.case2
    
  }
  

  enable_dns_hostnames = true

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

resource "aws_subnet" "publicsunet1" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = "172.16.0.0/20"
  #availability_zone = "${var.region}a" 

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "pubsunet_terraform"
  }

}

resource "aws_subnet" "privatesubnet1" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.16.0/20"
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
}

resource "aws_route_table_association" "topublic" {
  subnet_id      = aws_subnet.publicsunet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "toprivate" {
  subnet_id      = aws_subnet.privatesubnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_instance" "instancelinux01" {
  #name = "terraform-testing" #agregar un nombre a la instancia

  #Numero de servidores en base al tipo de instancias que se muestra en la variable instance type
  #count = length(var.instance_type)

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = "DockerOregon"
  #count = length(var.instance_type)
  #for_each = toset(var.name)
  #count = 2    

  #for_each = {
  #   "terraform": "infrastructure",
  #    "vault":     "security",
  #"consul":    "connectivity",
  #"nomad":     "scheduler",
  #}

  tags = {

    #Name = " ${var.region} - ${terraform.workspace} "
    Name = "server-terraform-${var.region}"
    #environment = each.value.environment

  }

  vpc_security_group_ids = [aws_security_group.securitygroup1.id]
  subnet_id              = aws_subnet.publicsunet1.id
  #subnet_id = module.vpc[each.key].public_subnets[*] #para lograr que una instancia este en su respectivo subred 

  associate_public_ip_address = true
  #user_data = file("./userdata.txt")

  #connection {
  #type     = "ssh"
  #user     = "ubuntu"
  #private_key = file("~/Downloads/DockerOregon.pem")
  #host     = self.public_ip
  #}

  #copiar un archivo local a la maquina virtual - esto pueda reemplazar el copiar la llave para el private server
  #provisioner "file" {
  #    source = "userdata.txt"
  #    destination = "/home/ubuntu/userdata.txt"
  #}

  #provisioner "remote-exec" {
  #on_failure = continue
  #    inline = [ "sudo apt update",
  #    "sudo apt install nginx -y",
  #    "sudo systemctl enable nginx",
  #    "sudo systemctl start nginx",
  #    ] # Es una lista de comandos string
  #}

  #provisioner "local-exec" {
  #   command = "echo testing-provisioner-local-exec >> /home/ubuntu/localexecfile.txt"
  #}
}

resource "aws_security_group" "securitygroup1" {
  name = "terraform-ssh-access"

  description = "Allow ssh connect to virtual machine"

  #for_each = var.project

  vpc_id = aws_vpc.main_vpc.id


  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#resource "aws_security_group" "securitygroup2" {
#
#        name = "terraform-http-access"
#        description = "Allow ssh connect to virtual machine"
#       vpc_id = module.vpc[each.key].vpc_id[1]
#
#        ingress {
#                from_port        = 80
#                to_port          = 80
#                protocol         = "tcp"
#                cidr_blocks      = ["0.0.0.0/0"]
#        }
#
#        egress {
#                from_port   = 0
#                to_port     = 0
#                protocol    = "-1"
#                cidr_blocks = ["0.0.0.0/0"]
#        }
#
#}



output "aws_instance_id" {

  value = aws_instance.instancelinux01.id

  #value = aws_instance.instancelinux01[each.key].public_ip
  #value = { for p in sort(keys(var.project)) : p => aws_instance.instancelinux01[p].public_ip }

  #insta = aws_instance.instancelinux01["terraform"].public_ip

}

#output publicip_instance_dev {
#        value = aws_instance.instancelinux01[1].public_ip
#}