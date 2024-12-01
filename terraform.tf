terraform {
  backend "s3" {
    key    = "state/terraform.tfstate"
    region = "us-west-2"
    bucket = "backendterraformtestingbucketpaul"
  }
}