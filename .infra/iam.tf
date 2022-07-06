data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role" "cloudwatch_discord_alarm_lambda" {
  name = "${var.cloudwatch_discord_alarm}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_discord_alarm_cloudwatch" {
  role       = aws_iam_role.cloudwatch_discord_alarm_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}







