resource "aws_s3_bucket" "primary_api_lambda_bucket" {
  bucket = "test-lambda-bucket-for-silver-project"
  region = "us-east-1"
}

resource "aws_s3_object" "health_check_code" {
  bucket = aws_s3_bucket.primary_api_lambda_bucket.id

  key    = "health-check-code.zip"
  source = data.archive_file.health_check_api.output_path

  etag = filemd5(data.archive_file.health_check_api.output_path)
}

resource "aws_s3_object" "silver_price_code" {
  bucket = aws_s3_bucket.primary_api_lambda_bucket.id
  key = "silver_spot_code.zip"
  source = data.archive_file.silver_price_api.output_path

  etag = filemd5(data.archive_file.silver_price_api.output_path)
}

resource "aws_s3_object" "silver_price_updater_code" {
  bucket = aws_s3_bucket.primary_api_lambda_bucket.id
  key = "update_silver_spot.zip"
  source = data.archive_file.silver_price_updater.output_path

  etag = filemd5(data.archive_file.silver_price_updater.output_path)
}