
import boto3
import json
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from decimal import Decimal
import requests


dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('SilverHistory') 
counter_table = dynamodb.Table('id-counter-table')

def lambda_handler(event, context):
  r = requests.get('https://api.gold-api.com/price/XAG')
  price_json = r.json()
  
  price = price_json['price']
  date = price_json['updatedAt']

  
  try:
    highest_id = get_next_id()
    new_id = highest_id + 1
    
    new_item = {
      'id': new_id,
      'price': Decimal(str(price)),
      'updatedAt': date
    }
    
    table.put_item(Item=new_item)
    
    return {
      'statusCode': 200,
      'body': json.dumps({
          'message': 'Item created successfully',
          'id': new_id,
          'item': convert_decimals(new_item)
      })
    }
  except Exception as e:
    print(f"Error: {str(e)}")
    return {
      'statusCode': 500,
      'body': json.dumps({
          'message': 'Error creating item',
          'error': str(e)
      })
    }

def get_next_id():
  try:
      response = counter_table.update_item(
          Key={'counter_name': 'item_id'},
          UpdateExpression='ADD current_value :inc',
          ExpressionAttributeValues={':inc': 1},
          ReturnValues='UPDATED_NEW'
      )
      return int(response['Attributes']['current_value'])
  except ClientError as e:
      if e.response['Error']['Code'] == 'ValidationException':
          counter_table.put_item(Item={'counter_name': 'item_id', 'current_value': 1})
          return 1
      raise

def convert_decimals(obj):
  if isinstance(obj, list):
    return [convert_decimals(i) for i in obj]
  elif isinstance(obj, dict):
    return {k: convert_decimals(v) for k, v in obj.items()}
  elif isinstance(obj, Decimal):
    return float(obj)
  else:
    return obj
  