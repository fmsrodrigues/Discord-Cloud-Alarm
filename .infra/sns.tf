resource "aws_sns_topic" "sns_alarms" {
  name = "${var.cloudwatch_discord_alarm}-sns-alarms"

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "lambda_alarm" {
  topic_arn = aws_sns_topic.sns_alarms.arn
  protocol  = "lambda"
  endpoint  = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.cloudwatch_discord_alarm}"
}
