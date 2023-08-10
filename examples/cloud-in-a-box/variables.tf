variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "localstack_url" {
  description = "LocalStack URL"
  type        = string
  default     = "http://localstack:4566"
}