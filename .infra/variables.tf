variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cloudwatch_discord_alarm" {
  type    = string
  default = "cloudwatch-discord-alarm"
}

locals {
  lambdas_path = "${path.module}/../lambdas"
  layers_path  = "${path.module}/../layers"

  common_tags = {
    Project   = "CloudWatch alarm with SNS to trigger Lambda layers to warn Discord users",
    CreatedAt = formatdate("YYYY-MM-DD", timestamp())
    ManagedBy = "Terraform"
    Owner     = "Filipe Rodrigues"
  }

  alarms_dimensions = {
    "${var.cloudwatch_discord_alarm}-lambda" = {
      FunctionName = "${var.cloudwatch_discord_alarm}-lambda"
    },
  }
}
