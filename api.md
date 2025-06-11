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

## 2a. `POST /send_email`

**Description:**
Sends an email with a verification code to the provided email address.

**Parameters:**
- `email` (string, required): The email address to send the verification code to.

**Response:**
```json
{
  "result": "ok",
  "email": "string"
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

## 3a. `POST /signin_with_email`

**Description:**
Signs in a user using email and verification code. Creates a user if not exists.

**Parameters:**
- `email` (string, required): The user's email address.
- `code` (string, required): The verification code sent via email.

**Response:**
```json
{
  "result": "ok",
  "auth_token": "string",
  "email": "string",
  "id": "string",
  "address_type": "email"
}
```

---

## 4. `POST /signin_with_password`

**Description:**
Signs in a user using phone and password. If the user does not exist, creates a new user with the provided phone and password.

**Parameters:**
- `phone` (string, required): The user's phone number.
- `password` (string, required): The user's password.

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

## 5. `POST /set_handle`

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

## 6. `POST /set_image_url`

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

## 7. `POST /set_encrypted_keys`

**Description:**
Sets the user's encrypted keys.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Parameters:**
- `id` (string, required): The user's ID.
- `encrypted_keys` (string, required): The encrypted keys.
- `evm_chain_address` (string, optional): The user's EVM chain contract address.
- `evm_chain_active_key` (string, optional): The user's EVM chain active key.

**Response:**
```json
{
  "result": "ok"
}
```

---

## 8. `GET /get_encrypted_keys`

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

## 9. `GET /get_user`

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

## 10. `POST /set_evm_chain_address`
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

---

## 11. `GET /get_me`

**Description:**
Retrieves information about the currently authenticated user.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Response:**
```json
{
  "id": "string",
  "handle": "string or null",
  "email": "string or null",
  "phone": "string",
  "image_url": "string or null",
  "evm_chain_address": "string or null",
  "evm_chain_active_key": "string or null",
  "remaining_gas_credits": number,
  "total_used_gas_credits": number
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

---

## 12. `POST /add_transaction`

**Description:**
Adds a transaction record for the authenticated user.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Parameters:**
- `tx_hash` (string, required): The transaction hash.
- `gas_used` (integer, required): The amount of gas used.
- `status` (string, required): The status of the transaction (e.g., "success").
- `chain` (string, required): The blockchain type (e.g., "evm").
- `data` (string, required): Additional data related to the transaction.

**Response:**
```json
{
  "result": "ok"
}
```

---

## 13. `GET /get_transactions`

**Description:**
Retrieves all transactions for the authenticated user.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Response:**
```json
{
  "transactions": [
    {
      "tx_hash": "string",
      "gas_used": number,
      "status": "string",
      "chain": "string",
      "data": "string",
      "created_at": "string"
    }
    // ... more transactions
  ]
}
```

---

## 14. `GET /remaining_free_transactions`

**Description:**
Retrieves the number of remaining free transactions for the authenticated user.

**Headers:**
- `Authorization: Bearer <auth_token>`

**Response:**
```json
{
  "remaining_free_transactions": number
}
```
