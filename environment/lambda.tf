resource "aws_lambda_function" "silver_price_updater" {
  function_name = "SilverUpdater"

  s3_bucket = aws_s3_bucket.primary_api_lambda_bucket.id
  s3_key = aws_s3_object.silver_price_updater_code.key
  layers = [aws_lambda_layer_version.requests_layer.arn]
  runtime = "python3.12"
  handler = "update_silver_spot.lambda_handler"
  source_code_hash = data.archive_file.silver_price_updater.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
  timeout = 10
}

resource "aws_lambda_function" "silver_price_lambda" {
  function_name = "Silver-Price"

  s3_bucket = aws_s3_bucket.primary_api_lambda_bucket.id
  s3_key = aws_s3_object.silver_price_code.key

  runtime = "python3.12"
  handler = "silver_spot.lambda_handler"
  source_code_hash = data.archive_file.silver_price_api.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
  timeout = 20

}

resource "aws_lambda_function" "health_check_lambda" {
  function_name = "Health-Check"

  s3_bucket = aws_s3_bucket.primary_api_lambda_bucket.id
  s3_key = aws_s3_object.health_check_code.key

  runtime = "python3.12"
  handler = "health-check.lambda_handler"
  source_code_hash = data.archive_file.health_check_api.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
  timeout = 10
}

resource "aws_lambda_layer_version" "requests_layer" {
  filename            = "../api/cron/update_silver_spot/requests_layer.zip"
  layer_name          = "requests-dependencies"
  compatible_runtimes = ["python3.11"]
  source_code_hash    = filebase64sha256("../api/cron/update_silver_spot/requests_layer.zip")
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.silver_price_updater.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lambda_every_5_minutes.arn
}

resource "aws_lambda_permission" "api_gw_silver_price" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.silver_price_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}