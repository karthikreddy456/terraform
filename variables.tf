# variable "aws_access_key" {
#   description = "AWS Access Key"
#   type        = string
# }

# variable "aws_secret_key" {
#   description = "AWS Secret Key"
#   type        = string
# }
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "name" {
  description = "Name of the VPC"
  type        = string
  default     = "project-vpc"
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones for the VPC"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "private_subnets" {
  description = "Private subnets for the VPC"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "public_subnets" {
  description = "Private subnets for the VPC"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

# variable "godaddy_api_key" {
#   description = "GoDaddy API Key"
#   type        = string

# }

# variable "godaddy_api_secret" {
#   description = "GoDaddy API Secret"
#   type        = string

# }

variable "domain_name" {
  description = "Domain name for the GoDaddy record"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain for the GoDaddy record"
  type        = string
  default     = ""

}

variable "validation_method" {
  description = "Validation method for the ACM certificate"
  type        = string
  default     = "DNS"
}

variable "domain_name_route53" {
  description = "Domain name for the ACM certificate"
  type        = string
  default     = ""

}