terraform {
  backend "s3" {
    bucket         = "acs-final-project-staging"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}