import boto3

def lambda_handler(event, context):
  status = "HEALTHY"
  return {
    'statusCode' : 200,
    'body' : status
  }