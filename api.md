# HomeController API Documentation

## Base URL

All endpoints are relative to your Rails server root (e.g., `http://localhost:3000/`).

---

## 1. `GET /`

**Description:**
Returns a simple hello world message.

**Response:**
```json
{
  "message": "Hello, World!"
}
```

---

## 2. `POST /send_sms`

**Description:**
Sends an SMS with a verification code to the provided phone number.

**Parameters:**
- `phone` (string, required): The phone number to send the SMS to.

**Response:**
```json
{
  "result": "ok"
}
```

---

## 3. `POST /signin`

**Description:**
Signs in a user using phone and verification code. Creates a user if not exists.

**Parameters:**
- `phone` (string, required): The user's phone number.
- `code` (string, required): The verification code sent via SMS.

**Response:**
```json
{
  "result": "ok",
  "auth_token": "string",
  "phone": "string",
  "id": "string",
  "address_type": "phone"
}
```

---

## 4. `POST /set_handle`

**Description:**
Sets the user's handle (username).

**Headers:**
- `Authorization: Bearer <auth_token>`

**Parameters:**
- `id` (string, required): The user's ID.
- `handle` (string, required): The new handle.

**Response:**
```json
{
  "result": "ok"
}
```

---

## 5. `POST /set_image_url`

**Description:**
Sets the user's image URL.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Parameters:**
- `id` (string, required): The user's ID.
- `image_url` (string, required): The new image URL.

**Response:**
```json
{
  "result": "ok"
}
```

---

## 6. `POST /set_encrypted_keys`

**Description:**
Sets the user's encrypted keys.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Parameters:**
- `id` (string, required): The user's ID.
- `encrypted_keys` (string, required): The encrypted keys.

**Response:**
```json
{
  "result": "ok"
}
```

---

## 7. `GET /get_encrypted_keys`

**Description:**
Retrieves the user's encrypted keys.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Parameters:**
- `id` (string, required): The user's ID.

**Response:**
```json
{
  "result": "ok",
  "encrypted_keys": "string"
}
```

---

## 8. `GET /get_user`

**Description:**
Retrieves user information.

**Parameters:**
- `id` (string, required): The user's ID.

**Response:**
```json
{
  "id": "string",
  "handle": "string or null",
  "email": "string or null",
  "phone": "string",
  "image_url": "string or null"
}
```

---

## 9. `POST /set_evm_chain_address`
**Description:**
Sets the user's EVM chain address.
**Headers:**
- `Authorization: Bearer <auth_token>`
**Parameters:**
- `id` (string, required): The user's ID.
- `evm_chain_address` (string, required): evm chain contract address
- `evm_chain_active_key` (string, required): evm chain active_key.
**Response:**
```json
{
  "result": "ok"
}
```


**Note:**
- Endpoints that modify user data require a valid `Authorization` header with a Bearer token.
- Error responses will be in the form:
  ```json
  {
    "error": "Error message"
  }
  ```