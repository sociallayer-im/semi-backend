# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Semi is a Rails 8 API-only backend for a cryptocurrency wallet application. It handles user authentication (phone/email/password), wallet management, blockchain transactions, and token class tracking.

## Common Commands

```bash
# Start the server
bin/rails server

# Run all tests
bin/rails test

# Run a single test file
bin/rails test test/models/user_test.rb

# Run a specific test by line number
bin/rails test test/models/user_test.rb:10

# Database operations
bin/rails db:migrate
bin/rails db:rollback
bin/rails db:seed

# Rails console
bin/rails console

# Linting (uses rubocop-rails-omakase)
bin/rubocop

# Security scan
bin/brakeman
```

## Architecture

### Authentication Flow
- Users authenticate via phone SMS code, email code, or password
- `VerificationToken` stores temporary codes with expiration
- On successful auth, `AuthToken` is created and returned to client
- Authenticated requests use `Authorization: Bearer <token>` header
- `current_user` helper in ApplicationController extracts user from token

### Custom ID Generation
Users and Wallets use TSID (Time-Sorted ID) instead of auto-increment integers. The generator is in `lib/tsid.rb` and produces 13-character sortable base32 strings.

### Models
- **User**: Core entity with phone/email auth, encrypted keys storage, gas credits tracking
- **Wallet**: User can have multiple wallets with encrypted keys
- **Transaction**: Blockchain transaction records linked to user
- **TokenClass**: Registry of ERC20/ERC721/ERC1155 tokens across chains
- **AuthToken**: Bearer tokens for API authentication
- **VerificationToken**: Temporary codes for phone/email verification

### Error Handling
Two custom error classes in ApplicationController:
- `AppError` → HTTP 400 with error message
- `AuthError` → HTTP 401 for authentication failures

### External Services
- **Aliyun SMS**: Phone verification (controlled by `SMS_ENABLED` env var)
- **Resend**: Email verification via `SigninMailer`

## Deployment

Deployed to Fly.io (see `fly.toml`). Uses PostgreSQL database.
