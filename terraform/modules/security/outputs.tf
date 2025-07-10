output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket name for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "config_s3_bucket" {
  description = "S3 bucket name for Config logs"
  value       = aws_s3_bucket.config_logs.bucket
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = data.aws_guardduty_detector.main.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "security_alarms" {
  description = "List of security CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.unauthorized_api_calls.alarm_name,
    aws_cloudwatch_metric_alarm.root_account_usage.alarm_name
  ]
} 