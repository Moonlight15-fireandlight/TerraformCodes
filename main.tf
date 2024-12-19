module "infraestructure_vpc" {

  source = "./modules/vpcaws"
  vpc_cidr = "172.16.0.0/16"
  cidr_pub_subnets = [ "172.16.0.0/20" ]
  cird_priv_subnets = [  ]

}

module "instance_ec2" {

  source = "./modules/Ec2instance"
  instance_type = "t2.micro"
  subnet_id = module.infraestructure_vpc.pub_sunet_id
  vpc_id = module.infraestructure_vpc.vpc_id
  region = "us-west-2"

}

module "elastic_ip" {
  source = "./modules/ElasticIp"
  instance_aws = module.instance_ec2.aws_instance_id

}