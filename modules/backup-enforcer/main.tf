module "erfgeo_lambda" {
  source = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  function_name = "erefgeo-backup-policy-enforcer"
  description   = "Set appropriate backup tags on erfgeo resources"
  handler       = "erfgeo-backup.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  source_path =  "./modules/backup-enforcer/lambda-src/erfgeo-backup.py"

  publish = true
  allowed_triggers = {
  }

  environment_variables = {
  }
  attach_policy_json = true
  policy_json = data.aws_iam_policy_document.lambda_extra_permissions.json
}

# lambda permissions

data "aws_iam_policy_document" "lambda_extra_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

# Cloudwatch Events (EventBridge)

resource "aws_cloudwatch_event_rule" "trigger_lambda" {
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = "${aws_cloudwatch_event_rule.trigger_lambda.name}"
  arn  = module.erfgeo_lambda.lambda_function_arn
}

