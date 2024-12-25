import json
import boto3
import os

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(os.environ['TABLE_NAME'])

    # ここでは、シンプルに1件のアイテムを put_item する例
    table.put_item(
        Item={
            "id": "1",
            "message": "Hello from Lambda"
        }
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"result": "Item created!"})
    }
