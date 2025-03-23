import boto3
import json
import kc_checker
import time
from datetime import datetime, timezone

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('kc_stones')

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
}


def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        print("Received body:", body)

        if isinstance(body, dict) and 'gameid_moves' in body and 'stones' in body:
            # パターン1: 全体に gameid_moves と stones が含まれる形式
            gameid_moves = body['gameid_moves']
            stones = body['stones']
            print("gameid_moves:", gameid_moves)

            created_at = datetime.now(timezone.utc).isoformat()  # ISO 8601形式のタイムスタンプ
            ttl = int(time.time()) + 86400

            try:
                # DynamoDB への登録
                table.put_item(
                    Item={
                        'gameid_moves': gameid_moves,
                        'created_at': created_at,
                        'ttl': ttl,
                        'stones': stones
                    }
                )
                print("Data written to DynamoDB successfully.")
            except Exception as e:
                print(f"Error writing to DynamoDB: {str(e)}")
                # DynamoDBエラーでも処理を続行する
            
            print("stones:", stones)

            player1_stones = stones["player1"]
            player2_stones = stones["player2"]

            player1_stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(player1_stones.items())]
            print("player1_stones_tuple:", player1_stones_tuple)
            player1_kc_flg = kc_checker.alert_on_square_or_pre_square(player1_stones_tuple)
            print("player1_kc_flg:", player1_kc_flg)

            player2_stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(player2_stones.items())]
            print("player2_stones_tuple:", player2_stones_tuple)
            player2_kc_flg = kc_checker.alert_on_square_or_pre_square(player2_stones_tuple)
            print("player2_kc_flg:", player2_kc_flg)

            kc_flg = {
                    "player1": player1_kc_flg,
                    "player2": player2_kc_flg
            }

        else:
            # パターン2: stones のみが直接来る形式
            stones = body

            print("stones:", stones)
            stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(stones.items())]
            print("stones_tuple:", stones_tuple)

            kc_flg = kc_checker.alert_on_square_or_pre_square(stones_tuple)
            # rtn_body = json.dumps({"kc_flg": kc_flg})

    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": "Invalid request stones"})
        }
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": "Internal server error"})
        }

    return {
        "statusCode": 200,
        "headers": CORS_HEADERS,
        "body": json.dumps({"kc_flg": kc_flg})
    }
