variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "alternate_domain_names" {
  description = "Additional domain names for CloudFront (e.g. www)"
  type        = list(string)
  default     = []
}