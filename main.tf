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

module "created_instance" {

  source        = "./modules/Ec2instance" #"(child module)"
  region        = var.region
  instance_type = lookup(var.instance_type, terraform.workspace)

  providers = {
    #aws = aws.eas #
  }

  #ami = "ami-0ea3c35c5c3284d82"

}

module "assign_eip" {

  source       = "./modules/ElasticIp"
  instance_aws = module.created_instance.aws_instance_id

}

#module "iam_iam-user" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
#  version = "5.47.1"
#  name = "user_for_test_module_terraform"
#  create_iam_access_key = false
#  create_iam_user_login_profile = false
# insert the 1 required variable here
#}

#module 