terraform {
  backend "s3" {
    bucket = "craig-godden-payne-terraform-state-files"
    key    = "development-vpc/terraform.tfstate"
    region = "eu-west-2"
    acl    = "bucket-owner-full-control"
  }
}