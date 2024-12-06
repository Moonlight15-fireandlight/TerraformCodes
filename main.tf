#resource "local_file" "state" {
#        content = "This configuration have ${var.change-state} state"
#        filename = "/root/${var.change-state}"
#}

#resource "random_pet" "my-pet" {
#        prefix = "Mrs"
#       separator = "."
#        length = "1"
#}

#resource "random_pet" "second-pet" {
#       prefix = var.prefix[2]
#       separator = "-"
#}

#resource "local_file" "test_variable" {
#
#        content = "testing var map ${var.example["one"]}"
#        filename = var.docker_port[0].filename1
#
#}

provider "aws" {

  alias  = "west-1"
  region = "us-west-1"

}

provider "aws" {

  alias = "west-2"
  region = "us-west-2"

}

module "created_instance" {

  for_each = var.create_ec2

  source        = "./modules/Ec2instance" #"(child module)"
  region        = each.value.region
  #instance_type = lookup(var.instance_type, terraform.workspace)
  instance_type = each.value.instance_type

  providers = {

    aws.case1 = aws.west-1
    aws.case2 = aws.west-2
    #aws.destination = aws.west-2

    #https://developer.hashicorp.com/terraform/language/providers/configuration
    #https://developer.hashicorp.com/terraform/language/meta-arguments/module-providers
    #https://developer.hashicorp.com/terraform/language/modules/develop/providers (proveedores dentro de modulos) 

  }

  #ami = "ami-0ea3c35c5c3284d82"

}

#module "assign_eip" {
#
#  source       = "./modules/ElasticIp"
#  instance_aws = module.created_instance.aws_instance_id
#
#}

#module "iam_iam-user" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
#  version = "5.47.1"
#  name = "user_for_test_module_terraform"
#  create_iam_access_key = false
#  create_iam_user_login_profile = false
# insert the 1 required variable here
#}

#module 