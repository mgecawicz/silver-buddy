resource "aws_cloudwatch_event_rule" "trigger_lambda_every_5_minutes" {
  name                = "get_price_every_5_mins"
  description         = "Fires every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

# Trigger our lambda based on the schedule
resource "aws_cloudwatch_event_target" "trigger_lambda_on_schedule" {
  rule      = aws_cloudwatch_event_rule.trigger_lambda_every_5_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.silver_price_updater.arn
}