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

resource "aws_dynamodb_table" "counter_table" {
  name           = "id-counter-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "counter_name"

  attribute {
    name = "counter_name"
    type = "S"
  }
}