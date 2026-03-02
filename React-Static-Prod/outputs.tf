#############################################
# S3 Outputs
#############################################

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
}

#############################################
# CloudFront Outputs
#############################################

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.cloudfront_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.cloudfront_distribution.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront Domain Name"
  value       = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

#############################################
# Website Access URL
#############################################

output "website_url" {
  description = "Production website URL"
  value       = "https://${var.domain_name}"
}

#############################################
# ACM Certificate
#############################################

output "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  value       = aws_acm_certificate.acm_certificate.arn
}

#############################################
# Route53
#############################################

output "route53_records" {
  value = {
    for k, v in aws_route53_record.route53_record :
    k => v.fqdn
  }
}

#############################################
# Website URLs
#############################################

output "website_urls" {
  value = concat(
    ["https://${var.domain_name}"],
    [for d in var.alternate_domain_names : "https://${d}"]
  )
}