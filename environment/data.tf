data "archive_file" "health_check_api" {
  type = "zip"

  source_file = "../api/test/health-check.py"
  output_path = "../api/health-check-code.zip"
}

data "archive_file" "silver_price_api" {
  type = "zip"

  source_file = "../api/getters/silver_spot.py"
  output_path = "../api/silver_spot_code.zip"
}

data "archive_file" "silver_price_updater" {
  type = "zip"

  source_file = "../api/cron/update_silver_spot/update_silver_spot.py"
  output_path = "../api/update_silver_spot.zip"
}