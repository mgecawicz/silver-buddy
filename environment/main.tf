provider "aws" {
  region = "us-east-1"
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

  attribute {
    name = "price"
    type = "S"
  }

  attribute {
    name = "date"
    type = "N"
  }
}