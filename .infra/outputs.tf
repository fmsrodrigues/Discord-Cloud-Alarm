output "layers" {
  value = [{
    dotenv = {
      arn         = aws_lambda_layer_version.dotenv.arn
      name        = aws_lambda_layer_version.dotenv.layer_name
      version     = aws_lambda_layer_version.dotenv.version
      description = aws_lambda_layer_version.dotenv.description
      created_at  = aws_lambda_layer_version.dotenv.created_date
    },
    got = {
      arn         = aws_lambda_layer_version.got.arn
      name        = aws_lambda_layer_version.got.layer_name
      version     = aws_lambda_layer_version.got.version
      description = aws_lambda_layer_version.got.description
      created_at  = aws_lambda_layer_version.got.created_date
    },
    regenerator_runtime = {
      arn         = aws_lambda_layer_version.regenerator_runtime.arn
      name        = aws_lambda_layer_version.regenerator_runtime.layer_name
      version     = aws_lambda_layer_version.regenerator_runtime.version
      description = aws_lambda_layer_version.regenerator_runtime.description
      created_at  = aws_lambda_layer_version.regenerator_runtime.created_date
    },
  }]
}

output "lambdas" {
  value = [{
    arn           = aws_lambda_function.cloudwatch_discord_alarm.arn
    name          = aws_lambda_function.cloudwatch_discord_alarm.function_name
    description   = aws_lambda_function.cloudwatch_discord_alarm.description
    version       = aws_lambda_function.cloudwatch_discord_alarm.version
    last_modified = aws_lambda_function.cloudwatch_discord_alarm.last_modified
  }]
}
