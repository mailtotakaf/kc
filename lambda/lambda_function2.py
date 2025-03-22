import json
import kc_checker


def lambda_handler(event, context):
    try:
        # print("event:", event)
        body = json.loads(event['body'])
        gid_uid_moves = body['gid_uid_moves']
        stones = body['stones']
        print("gid_uid_moves:", gid_uid_moves)
        print("stones:", stones)

        stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(stones.items())]
        print("stones_tuple:", stones_tuple)

        kc_flg = kc_checker.alert_on_square_or_pre_square(stones_tuple)

        CORS_HEADERS = {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
        }
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
