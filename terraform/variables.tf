locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

variable "workspace_iam_roles" {
  default = {
    dev             = "arn:aws:iam::683956285758:role/autumn-terraform-deploy-role"
  }
}

// Usage: export TF_VAR_EXTERNAL_ID="value"
// Ref: https://developer.hashicorp.com/terraform/language/values/variables#environment-variables

################################################################################
# Environment Variables
################################################################################
variable "project_name" {
  description = "Name of Project"
  type        = string
  default     = "scb"
}

variable "environment" {
  description = "Name of Environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_id" {
  description = "AWS Account"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "database_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
}

variable "s3_config" {
  description = "S3 Config"
  type        = map(string)
}

# WARNING: This variable is used to force destroy S3 bucket and all objects inside it.
variable "s3_force_destroy" {
  type    = bool
  default = false
}

variable "autoscaling_group" {
  description = "Autoscale group"
}

variable "load_balancer" {
  description = "Load Balancer"
}

