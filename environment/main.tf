provider "aws" {
  region = "us-east-1"
}

data "archive_file" "primary_api" {
  type = "zip"

  source_dir = "../api/test/"
  output_path = "../api/test.zip"
}

resource "aws_s3_bucket" "primary_api_lambda_bucket" {
  bucket = "test-lambda-bucket-for-silver-project"
  region = "us-east-1"
}

resource "aws_s3_object" "primary_api_code" {
  bucket = aws_s3_bucket.primary_api_lambda_bucket.id

  key    = "primary_api_code.zip"
  source = data.archive_file.primary_api.output_path

  etag = filemd5(data.archive_file.primary_api.output_path)
}

resource "aws_lambda_function" "silver_api_lambda" {
  function_name = "TestFunction"

  s3_bucket = aws_s3_bucket.primary_api_lambda_bucket.id
  s3_key = aws_s3_object.primary_api_code.key

  runtime = "nodejs20.x"
  handler = "api-health.handler"
  source_code_hash = data.archive_file.primary_api.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "test_lambda_function" {
  name = "/aws/lambda/${aws_lambda_function.silver_api_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_dynamodb_table" "silver_history" {
  name           = "SilverHistory"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "silver_api" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.silver_api_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "silver_api" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.silver_api.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.silver_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
