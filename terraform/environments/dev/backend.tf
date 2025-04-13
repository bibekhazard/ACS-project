terraform {
  backend "s3" {
    bucket         = "acs-final-project-dev"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}