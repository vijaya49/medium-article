#############################################
# S3 Bucket
#############################################

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.project_name}-${var.environment}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  depends_on = [ aws_cloudfront_distribution.cloudfront_distribution ]
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cloudfront_distribution.arn
          }
        }
      }
    ]
  })
}



#############################################
# CloudFront
#############################################

resource "aws_cloudfront_origin_access_control" "cloudfront_origin_access_control" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for React App"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}



resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  depends_on = [ aws_cloudfront_origin_access_control.cloudfront_origin_access_control, aws_s3_bucket.s3_bucket, aws_acm_certificate.acm_certificate, aws_route53_record.cert_validation  ]
  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class

  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_origin_access_control.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  # SPA Routing Support
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  viewer_certificate {
  acm_certificate_arn      = aws_acm_certificate.acm_certificate.arn
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
}

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = concat(
  [var.domain_name],
  var.alternate_domain_names
)
}

#############################################
# ACM Certificate
#############################################

resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  subject_alternative_names = var.alternate_domain_names
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "cert_validation" {
  depends_on = [ aws_acm_certificate.acm_certificate ]
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}


resource "aws_acm_certificate_validation" "acm_certificate_validation" {
depends_on = [ aws_acm_certificate.acm_certificate ]
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}



#############################################
# Route53
#############################################

locals {
  all_domains = concat(
    [var.domain_name],
    var.alternate_domain_names
  )
}

resource "aws_route53_record" "route53_record" {
depends_on = [ aws_cloudfront_distribution.cloudfront_distribution ]
for_each = toset(local.all_domains)
  zone_id = var.hosted_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}





