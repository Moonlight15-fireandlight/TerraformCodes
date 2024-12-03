resource "aws_eip" "lb" {
  #instance = aws_instance.web.id
  instance = var.instance_aws
  domain   = "vpc"
}