import boto3
import json
from boto3.dynamodb.conditions import Key
from decimal import Decimal


def lambda_handler(event, context):
  dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
  table = dynamodb.Table('SilverHistory')
  response = table.scan()
  items = response['Items']
  while 'LastEvaluatedKey' in response:
      response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
      items.extend(response['Items'])
  
  # Return None if table is empty
  if not items:
      return None
  
  # Find item with highest id
  highest_item = max(items, key=lambda x: int(x['id']))
  return {
      'statusCode' : 200,
      'body' : highest_item.get('price')
    }
  