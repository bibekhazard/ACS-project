terraform {
  backend "s3" {
    bucket         = "acs-final-project"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}