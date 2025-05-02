terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"
    }
    godaddy = {
      source  = "n3integration/godaddy"
      version = "1.9.1"
    }
  }
}

provider "aws" {
  region     = var.region
}


# provider "godaddy" {
#   key    = var.godaddy_api_key
#   secret = var.godaddy_api_secret
# }