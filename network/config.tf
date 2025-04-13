terraform {
  backend "s3" {
    bucket = "acs-730-group-bucket"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}