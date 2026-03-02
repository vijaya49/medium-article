#############################################
# S3 Outputs
#############################################

output "s3_bucket_name" {
  description = "S3 bucket name used for React app"
  value       = module.react_app.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.react_app.s3_bucket_arn
}

#############################################
# CloudFront Outputs
#############################################

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = module.react_app.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = module.react_app.cloudfront_domain_name
}

#############################################
# Website URL
#############################################

output "website_url" {
  description = "Production website URL"
  value       = module.react_app.website_urls
}

#############################################
# ACM Certificate
#############################################

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.react_app.acm_certificate_arn
}