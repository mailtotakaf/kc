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
"kc_flg" が返却される。
<br>
<br>
0： 通常時
```json
{
    "kc_flg": 0
}
```
1： リーチ
```json
{
    "kc_flg": 1
}
```
2： 積み
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

---

## Postman動作確認

https://v2vx0npl3f.execute-api.ap-northeast-1.amazonaws.com/dev/example

POSTでリクエストを送信
![alt text](image-1.png)

---

## Swagger EditerでAPI仕様確認

https://editor.swagger.io/
\
に swagger.yml を貼り付けて確認

---
## Git Hub

