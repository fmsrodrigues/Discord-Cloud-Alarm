resource "null_resource" "transpile_cloudwatch_discord_alarm" {
  triggers = {
    layer_build = filemd5("${local.lambdas_path}/${var.cloudwatch_discord_alarm}/src/index.ts")
  }

  provisioner "local-exec" {
    working_dir = "${local.lambdas_path}/${var.cloudwatch_discord_alarm}"
    command     = "npm run build"
  }
}

resource "null_resource" "copy_cloudwatch_discord_alarm_env_variables" {
  triggers = {
    env_file = filemd5("${local.lambdas_path}/${var.cloudwatch_discord_alarm}/.env")
  }

  provisioner "local-exec" {
    working_dir = "${local.lambdas_path}/${var.cloudwatch_discord_alarm}"
    command     = "cp .env ./dist"
  }
}

data "archive_file" "cloudwatch_discord_alarm_artefact" {
  output_path = "./../files/cloudwatch_discord_alarm.zip"
  type        = "zip"
  source_dir  = "${local.lambdas_path}/${var.cloudwatch_discord_alarm}/dist"

  depends_on = [
    null_resource.transpile_cloudwatch_discord_alarm,
    null_resource.copy_cloudwatch_discord_alarm_env_variables
  ]
}

resource "aws_lambda_function" "cloudwatch_discord_alarm" {
  function_name = var.cloudwatch_discord_alarm
  handler       = "index.handler"
  role          = aws_iam_role.cloudwatch_discord_alarm_lambda.arn
  runtime       = "nodejs16.x"

  filename         = data.archive_file.cloudwatch_discord_alarm_artefact.output_path
  source_code_hash = data.archive_file.cloudwatch_discord_alarm_artefact.output_base64sha256

  timeout     = 10
  memory_size = 128

  layers = [
    aws_lambda_layer_version.regenerator_runtime.arn,
    aws_lambda_layer_version.dotenv.arn,
    aws_lambda_layer_version.got.arn,
  ]

  tags = local.common_tags
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_discord_alarm.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns_alarms.arn
}
