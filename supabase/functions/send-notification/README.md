# 🔔 Smart Credit Card Payment & Billing Reminders

A robust and modular Deno service designed to send intelligent push
notifications for credit card billing dates, payment due dates, overdue
payments, and partial payment updates. This service runs on a schedule (e.g.,
daily via Postgres SQL Cron Jobs) and leverages Supabase for data management and
Firebase Cloud Messaging (FCM) for reliable notification delivery.

# ✨ Features

- Configurable Reminders: Users can set their preferred notification time.

- Localized Messages: Supports English and Hindi notification messages.

- Intelligent Due Reminders:

  - "Payment Due Today" and "Payment Due Tomorrow" specific messages.

  - Sends daily reminders when a payment is 10 days or less away.

  - Sends reminders once every 3 days if a payment is more than 10 days away.

- Dynamic Billing Date Reminders:

  - Notifies daily on the exact billing date.

  - Sends daily reminders for upcoming billing dates within 5 days.

  - Sends reminders once every 3 days for billing dates more than 5 days out.

- Adaptive Overdue Notifications:

  - Sends daily reminders for payments overdue up to 7 days.

  - Sends reminders once every 3 days for payments overdue more than 7 days.

- Partial Payment Alerts: Notifies users when a partial payment has been made,
  and a remaining balance exists, preventing redundant notifications for the
  same state.

- FCM Collapse Handling: Utilizes unique `tag` (Android) and `apns-collapse-id`
  (iOS) to prevent multiple notifications for the same user from collapsing into
  a single notification on the device.

- Stale Token Management: Automatically identifies and removes invalid FCM
  device tokens from the database.

- Comprehensive Logging: Logs all sent notifications to Supabase for auditing
  and debugging.

# 🏗️ Architecture

The service is built with a strong emphasis on modularity and OOP principles,
ensuring high maintainability and scalability.

```
.
├── main.ts                     # Entry point and orchestrator
├── models.ts                   # TypeScript interfaces for data structures
├── services/
│   ├── FirebaseService.ts      # Handles all Firebase Admin SDK (FCM) interactions
│   └── SupabaseService.ts      # Manages all Supabase database operations
├── notification/
│   ├── lang/
│   │   ├── en.ts               # English language strings
│   │   └── hi.ts               # Hindi language strings
│   ├── NotificationBuilder.ts  # Constructs localized notification messages
│   └── NotificationSender.ts   # Contains the core business logic for sending notifications based on intervals
└── utils/
    └── dateUtils.ts            # Utility functions for date calculations
```

# 🚀 Setup

To get this service up and running, you'll need a Supabase project and a
Firebase project.

1. Environment Variables Add Variables to your Supabase Function Secrets (or
   create a `.env` file directly in your project for testing):

```env
SUPABASE_URL="YOUR_SUPABASE_PROJECT_URL"
SUPABASE_SERVICE_ROLE_KEY="YOUR_SUPABASE_SERVICE_ROLE_KEY"
FIREBASE_SERVICE_ACCOUNT_JSON='{"type": "service_account", "project_id": "...", "private_key_id": "...", "private_key": "...", "client_email": "...", "client_id": "...", "auth_uri": "...", "token_uri": "...", "auth_provider_x509_cert_url": "...", "client_x509_cert_url": "...", "universe_domain": "..."}'
```

- `SUPABASE_URL`: Found in your Supabase project settings -> API.

- `SUPABASE_SERVICE_ROLE_KEY`: Found in your Supabase project settings -> API.
  This key has full access, so keep it secure.

- `FIREBASE_SERVICE_ACCOUNT_JSON`:

  1. Go to your Firebase project console.

  2. Navigate to Project settings ⚙️ > Service accounts.

  3. Click "Generate new private key" and then "Generate key".

  4. This will download a JSON file. Copy the entire content of this JSON file
     into the environment variable, ensuring it's a single-line string (no
     newlines) and properly escaped if needed (though Deno Deploy usually
     handles this well).

2. Supabase Database Setup You'll need the following tables in your Supabase
   project.

See - Table.sql

# 🏃 Usage

Once deployed and the cron job is configured, the service will automatically run
at the specified time(s) each day.

It fetches all users who have enabled notifications and whose reminder_time
matches the current execution time.

For each eligible user, it retrieves their cards and payments.

Based on the current date, due dates, billing dates, and the internal interval
logic (which checks the notification_logs for the last send of a specific type
for a card), it determines which notifications to send.

Notifications are sent via FCM to the user's registered device tokens.

All successful notifications are logged, and stale device tokens are removed.

# 🤝 Contributing

Contributions are welcome! Please feel free to open issues or submit pull
requests.

# 📄 License

This project is licensed under the MIT License.
