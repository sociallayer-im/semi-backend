# Project Knowledge Base

## 1. Project Overview
This is a Ruby on Rails backend application. The project structure and code indicate it is API-focused (using `ActionController::API`) and includes custom logic for SMS sending and TSID generation.

## 2. Directory Structure
- `app/` — Main application code
  - `controllers/` — API controllers (e.g., `HomeController`)
  - `models/` — Data models (only `ApplicationRecord` present)
  - `jobs/` — Background jobs (only base class present)
  - `mailers/` — Mailers (only base class present)
  - `views/` — View templates (only mailer layouts present)
- `config/` — Configuration files (routes, database, environments, etc.)
- `db/` — Database schema, seeds, and migrations
- `lib/` — Custom libraries (notably, a TSID generator)
- `script/`, `bin/`, `public/`, `test/`, `vendor/`, `storage/`, `log/`, `tmp/` — Standard Rails directories

## 3. Key Components
### Controllers
- **HomeController**
  - `index`: Root endpoint, returns `{ message: "Hello, World!" }` as JSON.
  - `send_sms`: Sends an SMS using Aliyun's SMS API (requires environment variables for credentials).
- **ApplicationController**: Inherits from `ActionController::API` (API-only Rails app).

### Models
- **ApplicationRecord**: Base model class. No custom models defined.
- **User**: Represents a user with the following fields:
  - `id`: String primary key, generated using the TSID generator (`lib/tsid.rb`).
  - `handle`: Unique username (string, required).
  - `email`: Unique email address (string, required).
  - `phone`: Phone number (string, optional).
  - `image_url`: URL to the user's image (string, optional).
  - Timestamps: `created_at`, `updated_at`.
  - Uniqueness is enforced on `handle` and `email`.

### Jobs & Mailers
- Only base classes (`ApplicationJob`, `ApplicationMailer`) are present. No custom jobs or mailers.

### Views
- Only mailer layouts (`mailer.html.erb`, `mailer.text.erb`).

### Lib
- **lib/tsid.rb**: Implements a TSID (Time-Sortable Identifier) generator with custom base32 encoding, monotonicity, and parsing logic.

## 4. Configuration
### Routing (`config/routes.rb`)
- `/up`: Health check endpoint.
- `/`: Root path, handled by `home#index`.

### Database
- Uses PostgreSQL (`pg` gem).
- Schema is empty except for enabling the `pg_catalog.plpgsql` extension.
- `users` table: String primary key (`id`), `handle`, `email`, `phone`, `image_url`, timestamps. Unique indexes on `handle` and `email`.

### Key Gems (from `Gemfile`)
- `rails` (~> 8.0.2)
- `pg` (PostgreSQL)
- `puma` (web server)
- `solid_cache`, `solid_queue`, `solid_cable` (Rails background/queue/caching)
- `http`, `rest-client`, `aliyunsdkcore` (HTTP clients, Aliyun SDK)
- `dotenv-rails` (environment variable management)
- Development/test: `debug`, `brakeman`, `rubocop-rails-omakase`

## 5. Custom Logic
### TSID Generator (`lib/tsid.rb`)
- Generates sortable, unique IDs using timestamp and random clock ID.
- Encodes/decodes to a custom base32 string.
- Ensures monotonicity for IDs generated in the same microsecond.

### SMS Sending (`HomeController#send_sms`)
- Uses Aliyun SMS API via `RPCClient`.
- Requires `ACCESS_KEY_ID` and `ACCESS_KEY_SECRET` environment variables.
- Sends a code to a phone number using a specific template.

## 6. How to Run
1. **Install dependencies:**
   ```sh
   bundle install
   ```
2. **Set up environment variables:**
   - Use `.env` or export `ACCESS_KEY_ID` and `ACCESS_KEY_SECRET` for SMS.
3. **Set up the database:**
   ```sh
   rails db:setup
   ```
4. **Run the server:**
   ```sh
   rails server
   ```
5. **Health check:**
   - Visit `GET /up` to verify the app is running.

---

*This file is auto-generated to help developers quickly understand the structure and logic of this Rails backend project.*