module "react_app" {
  source = "./React-Static-Prod"

  project_name   = var.project_name
  environment    = var.environment
  domain_name    = var.domain_name
  alternate_domain_names = var.alternate_domain_names
  hosted_zone_id = var.hosted_zone_id
  price_class    = var.price_class
  tags           = var.tags
}