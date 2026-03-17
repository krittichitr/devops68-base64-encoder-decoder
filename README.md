# Base64 Encoder/Decoder API

Encode text to Base64 or decode Base64 to text.

## Endpoints

### GET `/encode`

**Parameters:**
- `text` (required): Text to encode

**Example Request:**
```
http://localhost:3027/encode?text=hello
```

**Example Response:**
```json
{
  "input": "hello",
  "encoded": "aGVsbG8="
}
```

### GET `/decode`

**Parameters:**
- `text` (required): Base64 text to decode

**Example Request:**
```
http://localhost:3027/decode?text=aGVsbG8=
```

**Example Response:**
```json
{
  "input": "aGVsbG8=",
  "decoded": "hello"
}
```
