data "aws_ami" "ubuntu" {

  most_recent = true             #la version mas reciente
  owners      = ["099720109477"] #owner of the ami

  #        filter {
  #               name = "name"
  #               values = ["amazon/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240927"]
  #       }

}

resource "aws_instance" "instancelinux01" {

  count = length(var.subnet_id)
  #name = "terraform-testing" #agregar un nombre a la instancia

  #Numero de servidores en base al tipo de instancias que se muestra en la variable instance type
  #count = length(var.instance_type)

  ami           = var.ami
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
  subnet_id              = var.subnet_id[count.index] # para una sola subred
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

  #depends_on = [ aws_internet_gateway.igw ] #Como exportar esto

}

resource "aws_security_group" "securitygroup1" {
  name = "terraform-ssh-access"

  description = "Allow ssh connect to virtual machine"

  #for_each = var.project

  vpc_id = var.vpc_id

  dynamic "ingress" {

    for_each = var.inbound_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
  }

  dynamic "egress" {

    for_each = var.outbound_ports

    content {

      from_port = egress.value
      to_port   = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
    
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

  value = aws_instance.instancelinux01.*.id

  #value = aws_instance.instancelinux01[each.key].public_ip
  #value = { for p in sort(keys(var.project)) : p => aws_instance.instancelinux01[p].public_ip }

  #insta = aws_instance.instancelinux01["terraform"].public_ip

}

#output publicip_instance_dev {
#        value = aws_instance.instancelinux01[1].public_ip
#}