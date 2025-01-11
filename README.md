# KC_API
## リクエストサンプル

### リーチ状態（正方形１つ前）
- 横のパターン
```json
{
    "stone0": {"x": 0, "y": 0},
    "stone1": {"x": 0, "y": 1},
    "stone2": {"x": 1, "y": 0},
    "stone3": {"x": 2, "y": 2}
}
```
- 斜めのパターン
```json
{
    "stone0": {"x": 1, "y": 0},
    "stone1": {"x": 0, "y": 1},
    "stone2": {"x": 2, "y": 1},
    "stone3": {"x": 2, "y": 2}
}
```

### 積み（正方形）
- 横のパターン
```json
{
    "stone0": {"x": 0, "y": 0},
    "stone1": {"x": 0, "y": 1},
    "stone2": {"x": 1, "y": 0},
    "stone3": {"x": 1, "y": 1}
}
```
- 斜めのパターン
```json
{
    "stone0": {"x": 1, "y": 0},
    "stone1": {"x": 0, "y": 1},
    "stone2": {"x": 2, "y": 1},
    "stone3": {"x": 1, "y": 2}
}
```
### 通常時
```json
{
    "stone0": {"x": 1, "y": 0},
    "stone1": {"x": 0, "y": 1},
    "stone2": {"x": 2, "y": 1},
    "stone3": {"x": 3, "y": 2}
}
```
## レスポンス

### 200: OK
通常時
```json
{
    "kc_flg": 0
}
```
<br/>

リーチ
```json
{
    "kc_flg": 1
}
```
<br/>

積み
```json
{
    "kc_flg": 2
}
```
<br><br>
### 400: エラー
リクエストが不正
<br><br>
### 500: エラー
サーバーエラー

<br><br>
<br><br>
---

## Postman動作確認

https://6dhxw65lpc.execute-api.ap-northeast-1.amazonaws.com/dev/example

POSTでリクエストを送信
![alt text](img/image-1.png)

---
<br><br>
## Swagger EditerでAPI仕様確認

https://editor.swagger.io/
\
に swagger.yml を貼り付けて確認

<br><br>
---
## Git Hub
https://github.com/mailtotakaf/kc

