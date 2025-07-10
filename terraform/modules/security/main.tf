terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Cloud Native Security Controls Module
# This module implements preventive and detective controls to detect intentional misconfigurations

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "wiz-cloudtrail-logs-${random_id.suffix.hex}"
  tags = {
    Name = "wiz-cloudtrail-logs"
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail for comprehensive audit logging
resource "aws_cloudtrail" "main" {
  name                          = "wiz-cloudtrail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  tags = {
    Name = "wiz-cloudtrail"
  }
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/wiz-cloudtrail"
  retention_in_days = 30
}

# CloudTrail CloudWatch Logs
resource "aws_cloudtrail" "cloudwatch" {
  name                          = "wiz-cloudtrail-cloudwatch"
  s3_bucket_name               = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  tags = {
    Name = "wiz-cloudtrail-cloudwatch"
  }
}

# IAM Role for CloudTrail CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "wiz-cloudtrail-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "wiz-cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# AWS Config for compliance monitoring
resource "aws_config_configuration_recorder" "main" {
  name     = "wiz-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "wiz-config-delivery"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

# S3 Bucket for Config logs
resource "aws_s3_bucket" "config_logs" {
  bucket = "wiz-config-logs-${random_id.suffix.hex}"
  tags = {
    Name = "wiz-config-logs"
  }
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role for Config
resource "aws_iam_role" "config" {
  name = "wiz-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# Custom policy for AWS Config instead of managed policy
resource "aws_iam_role_policy" "config_custom" {
  name = "wiz-config-custom-policy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "config:Put*",
          "config:Get*",
          "config:List*",
          "config:Describe*",
          "config:Select*",
          "config:Deliver*",
          "config:Stop*",
          "config:Start*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.config_logs.arn,
          "${aws_s3_bucket.config_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

# Remove the managed policy attachment since we're using custom policy
# resource "aws_iam_role_policy_attachment" "config" {
#   role       = aws_iam_role.config.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSConfigRole"
# }

resource "aws_iam_role_policy" "config_s3_write" {
  name = "wiz-config-s3-write"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "${aws_s3_bucket.config_logs.arn}/*",
          aws_s3_bucket.config_logs.arn
        ]
      }
    ]
  })
}

# Use existing GuardDuty detector instead of creating a new one
data "aws_guardduty_detector" "main" {
  # This will use the existing detector in the account
}

# Comment out the resource creation since detector already exists
# resource "aws_guardduty_detector" "main" {
#   enable = true
# }

# Config Rules to detect intentional misconfigurations
# resource "aws_config_rule" "security_groups_restricted_common_ports" {
#   name = "security-groups-restricted-common-ports"
#
#   source {
#     owner             = "AWS"
#     source_identifier = "SECURITY_GROUPS_RESTRICTED_INBOUND_TRAFFIC_ALERT"
#   }
#
#   depends_on = [aws_config_configuration_recorder.main]
# }
#
# resource "aws_config_rule" "s3_bucket_public_read_prohibited" {
#   name = "s3-bucket-public-read-prohibited"
#
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
#   }
#
#   depends_on = [aws_config_configuration_recorder.main]
# }
#
# resource "aws_config_rule" "s3_bucket_public_write_prohibited" {
#   name = "s3-bucket-public-write-prohibited"
#
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
#   }
#
#   depends_on = [aws_config_configuration_recorder.main]
# }
#
# resource "aws_config_rule" "ec2_instances_in_vpc" {
#   name = "ec2-instances-in-vpc"
#
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_INSTANCES_IN_VPC"
#   }
#
#   depends_on = [aws_config_configuration_recorder.main]
# }
#
# resource "aws_config_rule" "iam_user_no_policies_check" {
#   name = "iam-user-no-policies-check"
#
#   source {
#     owner             = "AWS"
#     source_identifier = "IAM_USER_NO_POLICIES_CHECK"
#   }
#
#   depends_on = [aws_config_configuration_recorder.main]
# }

# CloudWatch Alarms for security events
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "wiz-unauthorized-api-calls"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "AWS/CloudTrail"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Monitor for unauthorized API calls"
  alarm_actions       = []

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudtrail.name
  }
}

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "wiz-root-account-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootAccountUsage"
  namespace           = "AWS/CloudTrail"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Monitor for root account usage"
  alarm_actions       = []

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudtrail.name
  }
}

# SCP (Service Control Policy) to restrict overly permissive permissions
resource "aws_organizations_policy" "restrict_permissions" {
  count = var.create_organization_policy ? 1 : 0
  
  name = "wiz-restrict-permissions"
  type = "SERVICE_CONTROL_POLICY"
  
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyOverlyPermissiveSecurityGroups"
        Effect = "Deny"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:SecurityGroupIngress": [
              "0.0.0.0/0"
            ]
          }
        }
      },
      {
        Sid    = "DenyPublicS3Buckets"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketPolicy"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "s3:PublicAccessBlock": "false"
          }
        }
      }
    ]
  })
}

# Random ID for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
} 