variable "create_organization_policy" {
  description = "Whether to create AWS Organizations SCP policy (requires Organizations access)"
  type        = bool
  default     = false
}

variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs in CloudWatch"
  type        = number
  default     = 30
}

variable "config_log_retention_days" {
  description = "Number of days to retain Config logs"
  type        = number
  default     = 30
} 