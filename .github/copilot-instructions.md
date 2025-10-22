<!-- Short, focused instructions to help AI coding agents be productive in this repo -->
# Copilot / AI agent instructions — Card Nudge (credit_card_manager)

Purpose: give concise, actionable context so an AI coding agent can make safe, useful edits quickly.

- Big picture
  - Flutter app (Material3) using Riverpod for state, Hive for local storage, and Supabase for cloud sync. Entry points:
    - `lib/main.dart` — initializes .env, Firebase, Supabase, Hive boxes and NotificationTapHandler.
    - `lib/credit_card_app.dart` — app widget: Riverpod `ProviderScope`, `routerProvider`, themes, locale settings.
  - Major folders:
    - `lib/data/` — Hive models/adapters and storage (`data/hive/...`), look for `*Storage.initHive()` patterns.
    - `lib/presentation/` — UI, screens, and `presentation/providers/` (Riverpod providers and router).
    - `lib/services/` — platform integrations (Supabase, sync, navigation).
    - `lib/helper/` — small utilities (e.g., `notification_handler.dart`).

- Important architectural patterns to know
  - Local-first sync: models have a `syncPending` flag. The canonical sync logic lives in `lib/services/sync_service.dart`; peer-reviewed edits should preserve its batching, upsert, and delete-queue behavior.
  - Delete queue: local deletes are enqueued (see `DeleteQueueEntry` and `delete_queue_entry_storage.dart`) and processed by `SyncService` before pulls.
  - Settings time conversion: reminder times are stored/sent in UTC on the server; the code converts to/from local in `sync_service.dart`. When changing settings, be careful with timezone conversions.
  - Auth & notifications: `lib/services/supabase_service.dart` handles OAuth, user sync, and FCM token management (table: `device_tokens`). iOS simulator behavior is specially handled (`isIosSimulator`).

- Key integration points (server table names & uses)
  - Supabase tables referenced in `sync_service.dart` and `supabase_service.dart`: `banks`, `cards`, `payments`, `settings`, `credit_card_summaries`, `default_banks`, `device_tokens`.
  - Notification routing: payloads map to `AppRoutes` (see `lib/constants/app_routes.dart`) and are handled by `NotificationTapHandler` (`lib/helper/notification_handler.dart`).

- Developer workflows & commands (must-run to build correctly)
  - Install deps: `flutter pub get`
  - Generate Hive adapters / codegen: `flutter packages pub run build_runner build --delete-conflicting-outputs`
  - Generate localization: `flutter gen-l10n`
  - Run app: `flutter run` (or `flutter run -d <device>` for specific device)
  - A PowerShell helper exists for Android builds: `build_android.ps1` (root).
  - Runtime env: a `.env` file is required (see `pubspec.yaml` lists `.env` as an asset). Required keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_*_CLIENT_ID`.

- Project-specific conventions to follow when editing
  - Providers live in `lib/presentation/providers/`. Add new service providers there and expose them as `final fooProvider = Provider<Foo>((ref) => Foo(ref));`.
  - Services expect a `Ref` or the `Supabase.instance.client` (see `supabase_service.dart` and `sync_provider.dart`). Prefer wiring via providers instead of global singletons.
  - Storage pattern: each storage class exposes `initHive()` called from `main.dart` and `getBox()` used by providers and services. When adding a new model, implement `initHive()` and update `main.dart` to initialize it.
  - Sync contract: `sync_service.dart` upserts local objects where `syncPending == true` and applies server-side updates when `server.updated_at` is newer. When adding new fields, update both client model mapping and the upsert payloads.
  - Use `syncPending` rather than ad-hoc flags; this repository relies on it to avoid duplicate uploads.

- Examples & quick references
  - Trigger a manual sync from code/tests: `ref.read(syncServiceProvider).syncData()` (see `lib/presentation/providers/sync_provider.dart`).
  - Initialize Supabase in tests/local scripts: call `SupabaseService.initialize()` which loads `.env` then `Supabase.initialize(...)` (see `lib/services/supabase_service.dart`).
  - Safe navigation from notifications: `NotificationTapHandler.handleNotificationTap(payload)` routes to allowed paths — check `notification_handler.dart` for allowed routes and how card-id payloads are parsed (`/cards/<id>`).
  - Lookups: find usage of a model's storage by searching for `SomeModelStorage.getBox()` or `initHive()`.

- Small gotchas to watch for
  - Timezones for reminder time conversions (local ↔ UTC) are implemented and must be preserved when editing settings sync.
  - FCM token handling distinguishes iOS simulator vs physical device. Tests or local runs on iOS simulator may return APNS tokens — follow `isIosSimulator()` behavior.
  - `.env` is required and listed under `flutter.assets`. CI/builds must provide these env keys or initialization will throw in `main.dart`.

If anything here is unclear or you want more specific examples (tests, a sample change walkthrough, or a summary of a particular file), tell me which area to expand and I will update this file.
