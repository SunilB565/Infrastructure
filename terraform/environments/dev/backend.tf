terraform {
  backend "s3" {
    bucket  = "hospital-management-hackathon"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
