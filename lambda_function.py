import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
# テーブル名を環境変数から取得する場合など
# table_name = os.environ['TABLE_NAME']
# table = dynamodb.Table(table_name)
# 今回は固定的にテーブルを指定
table = dynamodb.Table('example-table')

def lambda_handler(event, context):
    # クエリパラメータなどの取得例
    # query_params = event.get("queryStringParameters", {})

    # DynamoDBへの読み書きの例
    # table.put_item(Item={"id": "123", "value": "Hello DynamoDB"})
    # response = table.get_item(Key={"id": "123"})
    # item = response.get("Item")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from Lambda!",
            # "item": item
        })
    }
