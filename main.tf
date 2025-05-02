module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.name
  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

# Create a security group for ALB and EC2 instances
# This module creates a security group for ALB and EC2 instances in the VPC created above.
module "security-groups" {

  source = "./modules/securitygroups"

  vpc_id = module.vpc.vpc_id

}
module "loadbalancer" {
  source             = "./modules/loadbalancer"
  alb_name           = "load-balancer"
  vpc_id             = module.vpc.vpc_id
  certificate_arn    = aws_acm_certificate_validation.web.certificate_arn
  alb_subnets        = module.vpc.public_subnets
  alb_security_group = [module.security-groups.alb_security_group_id]
}

module "ASG" {
  source              = "./modules/ASG"
  asg_securuity_group = [module.security-groups.ec2_security_group_id]
  vpc_zone_identifier = module.vpc.private_subnets
  lb_target_group_arn = module.loadbalancer.alb_target_group_arn
}

# resource "godaddy_record" "www" {
#   domain = var.domain_name
#   name   = var.subdomain        
#   type   = "CNAME"
#   ttl    = 600
#   value  = module.loadbalancer.alb_dns_name  
# }


# 1) Request the ACM cert
resource "aws_acm_certificate" "web" {
  domain_name       = var.domain_name
  validation_method = var.validation_method

  # subject_alternative_names = [
  #   "poc.karthikdevops.life",
  # ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_zone" "main" {
  name = var.domain_name_route53
}

# 3) For each DNS validation option, make a CNAME in Route 53
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.web.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# 4) Tell ACM to validate once Route 53 records exist
resource "aws_acm_certificate_validation" "web" {
  certificate_arn = aws_acm_certificate.web.arn
  validation_record_fqdns = [
    for r in aws_route53_record.cert_validation : r.fqdn
  ]
}

# resource "aws_route53_record" "root_alias" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "karthikdevops.life"
#   type    = "A"
#   alias {
#     name                   = module.loadbalancer.alb_dns_name
#     zone_id                = module.loadbalancer.alb_zone_id
#     evaluate_target_health = true
#   }
# }

resource "aws_route53_record" "poc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.subdomain
  type    = "CNAME"
  ttl     = 300
  records = [module.loadbalancer.alb_dns_name]
}


