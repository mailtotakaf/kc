import json
import kc_checker


def lambda_handler(event, context):
    try:
        stones = json.loads(event['body'])
        stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(stones.items())]
        kc_flg = kc_checker.alert_on_square_or_pre_square(stones_tuple)
    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": "Invalid request stones"})
        }
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": "Internal server error"})
        }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({"kc_flg": kc_flg})
    }
