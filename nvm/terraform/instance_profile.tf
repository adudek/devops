data "aws_iam_policy_document" "cloudwatch_log_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:PutMetricData",
      "cloudwatch:SetAlarmState",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [ "*" ]
  }
}

data "aws_iam_policy_document" "ec2_cloudwatch_logging_trust" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type        = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role" "ec2_cloudwatch_logging" {
  name = "ec2-cloudwatch-logging"
  assume_role_policy = data.aws_iam_policy_document.ec2_cloudwatch_logging_trust.json
}

resource "aws_iam_role_policy" "ec2_cloudwatch_logging" {
  name   = "cloudwatch-log-permissions"
  role   = aws_iam_role.ec2_cloudwatch_logging.name
  policy = data.aws_iam_policy_document.cloudwatch_log_permissions.json
}

resource "aws_iam_instance_profile" "ec2_cloudwatch_logging" {
  name = "ec2-cloudwatch-logging"
  role = aws_iam_role.ec2_cloudwatch_logging.name
}
