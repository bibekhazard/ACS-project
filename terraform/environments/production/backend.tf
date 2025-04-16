terraform {
  backend "s3" {
    bucket         = "acs730-final-proj2"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}