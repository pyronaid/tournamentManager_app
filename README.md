# Tournament Manager

Tournament Manager is a mobile app (Flutter, Android/iOS first, web partially) for
**organising and playing in local trading-card-game tournaments** — mainly Yu-Gi-Oh!
retro formats (GOAT, Edison, Hat, WindUp, Tengu, …).

- **Organizers** create a tournament, manage the player lists, publish news,
  generate Swiss / top-cut rounds, enter match results, and close the tournament
  with its winner(s).
- **Players** find tournaments near them on a map, follow the ones they are enrolled
  in, submit a decklist, and see pairings, standings and news in real time
  (with push notifications planned for new pairings).

> A detailed list of defects and low-quality areas found during the code review
> is in [`docs/CODE_REVIEW.md`](docs/CODE_REVIEW.md). Read it before deploying
> to production: it includes **security issues in the backend access rules**.

---

## Features

| Area | What it does |
|---|---|
| Authentication | Email + password sign-up/sign-in, email verification, password reset, OTP endpoints, account deletion (PocketBase `users` collection). Session token kept in `flutter_secure_storage`. |
| Onboarding | Splash, slideshow, create account, verify email screens. |
| Tournament finder | Map (`flutter_map` + marker clusters) and list of `ready` tournaments around the user's location, filtered by game. |
| My / Own tournaments | Tournaments the user is enrolled in, and tournaments the user organises. |
| Create tournament | Name, game, date, capacity, address (Google Places autocomplete), online flag, pre-registration and waiting-list switches, image. |
| Tournament detail | State machine `open → ready → ongoing → close`, editable settings for the owner, counters, winner card. |
| People | Three lists — **registered**, **pre-registered**, **waiting** — with search, paging, promotion/removal. Players are added by scanning their QR code (`mobile_scanner`). Capacity is enforced server side. |
| Decklist | Players submit a decklist (main/extra/side) with card data from the YGOPRODeck API and an image. |
| News | Organizer posts news (title, subtitle, body, image) visible to enrolled players. |
| Rounds & pairings | Server-side generation of **Swiss** rounds (point groups, rematch avoidance, byes) and **top-cut** rounds (seeded 1 vs N, byes to reach a power of two). Results: win, double loss, no-show, drop. |
| Rankings | Points and tie-breakers (T1/T2/T3, opponents' win % style) computed by SQL views. |
| Notifications | FCM tokens stored per device; Go hook (not yet wired) calls an external Express/Vercel service to push pairing notifications. |

---

## Architecture

```
┌──────────────────────────────┐        REST + realtime (SSE)        ┌───────────────────────────────┐
│ Flutter app  (lib/)          │ ──────────────────────────────────► │ Extended PocketBase (Go)      │
│  • go_router + nested shells │                                     │  __pocketbase/                │
│  • Provider (ChangeNotifier) │  custom endpoints                   │  • SQLite + collections/views │
│  • get_it service locator    │  /api/tournamentManager/*           │  • enrollment / round APIs    │
│  • pocketbase Dart SDK       │ ──────────────────────────────────► │  • record hooks               │
└──────────────┬───────────────┘                                     └──────────────┬────────────────┘
               │ App Check, FCM, Analytics, callable function                        │ HTTP (push)
               ▼                                                                     ▼
┌──────────────────────────────┐                                     ┌───────────────────────────────┐
│ Firebase                     │                                     │ tournamentmanager_express-js  │
│  • getApiKeyFromSecret (fn)  │                                     │ (Vercel) → FCM send           │
│  • Messaging / App Check     │                                     └───────────────────────────────┘
└──────────────────────────────┘
```

The project started on **Firebase/Firestore** (originally generated with FlutterFlow)
and was migrated to **PocketBase**. Firebase is still used for App Check, Cloud
Messaging, Analytics and one callable function that hands out the Google Places
API key. The Firestore rules and most Cloud Functions under `__firebase/` are
legacy and no longer used by the app.

### Repository layout

```
lib/
├── main.dart                     App bootstrap: Firebase init, service locator, session restore, router
├── app_flow/
│   ├── app_config.dart           Build-time config via --dart-define (POCKETBASE_BASE_URL, RECAPTCHA_V3_SITE_KEY)
│   ├── nav/                      go_router config, route guards, route tables (auth / first level / tournament)
│   ├── services/                 get_it services: snackbar, loader, image picker, Places API, card API,
│   │                             PocketBase custom-API HTTP client, device tokens, external apps
│   ├── app_flow_theme.dart       Theme + typography (legacy FlutterFlow style)
│   └── …                         utils, widgets, animations, localisation stub
├── auth/
│   ├── base_auth_user_provider.dart   AppStateNotifier (auth state for the router)
│   └── pocketbase_auth/               PocketBase client singleton, auth manager, user stream, user record
├── backend/
│   ├── schema/                   One *Record class per PocketBase collection/view (parsing + CRUD + realtime streams)
│   ├── firebase/                 Firebase init (App Check, FCM, local notifications)
│   └── firebase_analytics/       Analytics helpers
├── components/                   Reusable cards and widgets (tournament, pairing, ranking, news, …)
└── pages/
    ├── onboarding/               splash, slideshow, sign-in, sign-up, verify mail, forgot password
    ├── profile/                  profile, edit profile/preferences, about us, support
    ├── nav_bar/                  Shell scaffolds + TournamentModel (shared state of one tournament)
    └── core/                     finder, my/own tournaments, create, detail, people, add people (QR),
                                  decklist, news, rounds, pairings, rankings

Each page follows the pattern  <page>_container.dart  (creates the ChangeNotifierProvider)
                            →  <page>_model.dart      (state + backend calls)
                            →  <page>_widget.dart     (UI)

__pocketbase/
├── main.go                       Registers custom APIs and hooks; imports pb_schema.json on a fresh DB
├── internals/apis/               enroll / delete / getUserInfo, generateRound / deleteRound / closeTournament
├── internals/hooks/              lastUpdated_* bump hooks, push-notification hook (WIP)
├── pb_schema.json                Collections, views and access rules (source of truth for new installs)
├── pb_migrations/                Historic auto-generated migrations
├── view_tables_code/             SQL of the views (rankings, pairings, rounds, enrollments, tournament stats)
├── Dockerfile, docker-compose.yml, Caddyfile
__firebase/                       Legacy Firestore rules, Cloud Functions (TypeScript), Storage rules
__express/                        Pointer to the Express push-notification service
```

### Data model (PocketBase)

| Collection | Purpose |
|---|---|
| `users` | Auth collection: name, surname, username, avatar, phone, `organizer` flag |
| `tournaments` | Owner, game, date, capacity, state, address/lat/long, flags, winners, `lastUpdated_*` timestamps |
| `enrollments` | User ↔ tournament with `listKind` (`registered` / `preregistered` / `waiting`) and decklist |
| `rounds` | Round index, size and kind (`swiss` / `topcut`) |
| `pairings` | Player A/B, table, winner, bye, double loss, no-show, drops |
| `rankings` | One row per player per round (input of the ranking view) |
| `news` | Tournament news |
| `device_tokens` | FCM tokens per user/device |
| `*_extended`, `tournament_with_stats` | SQL views joining names, counters, points and tie-breakers |

**Change propagation:** list screens do not subscribe to every collection. Server
hooks bump `tournaments.lastUpdated_news / _enrollments / _rounds`, the app
subscribes to the single tournament record (`TournamentModel`) and child pages
refresh their paged lists when the matching timestamp changes.

---

## Getting started

👉 **Full step-by-step guide: [`docs/LOCAL_SETUP.md`](docs/LOCAL_SETUP.md)**: backend,
admin user, test accounts, emulator networking, Firebase notes and troubleshooting.

Quick version (Android emulator):

```bash
# 1. Backend: imports pb_schema.json on first start
cd __pocketbase
go run . serve --http=0.0.0.0:8090
go run . superuser upsert admin@example.com 'Admin12345!'   # in a second terminal
#    → dashboard at http://localhost:8090/_/

# 2. Temporary edit (do not commit): point the SDK client to your machine
#    lib/auth/pocketbase_auth/pocketbase_auth_util.dart
#    final PocketBase pb = PocketBase('http://10.0.2.2:8090');

# 3. App
flutter pub get
flutter run --dart-define=POCKETBASE_BASE_URL=http://10.0.2.2:8090
```

4. Sign up in the app, then in the dashboard tick **verified** (no SMTP locally) and
   **organizer** (to create and manage tournaments) on that user.

For production: put the backend behind TLS (`__pocketbase/Caddyfile` is a template),
deploy `getApiKeyFromSecret` with the `SECRET_PAK` secret, and register the release
signing certificates for App Check in the Firebase console.

---

## Android build notes

- If the Android project is broken, back up `android/`, delete it and recreate it
  with `flutter create .`.
- Check the toolchain with `flutter doctor -v`.
- Check the Gradle ↔ Java compatibility matrix
  (<https://docs.gradle.org/current/userguide/compatibility.html#java>);
  e.g. Java 21 needs Gradle ≥ 8.5: `./gradlew wrapper --gradle-version 8.5`.
- Plugins without a namespace: add to `android/build.gradle`

  ```groovy
  subprojects {
    afterEvaluate { project ->
      if (project.hasProperty('android')) {
        project.android {
          if (namespace == null) { namespace project.group }
        }
      }
    }
  }
  ```
- Google Play requires targetSdk ≥ 33. Set `minSdk`, `compileSdk`, `targetSdk`
  and `ndkVersion` in `android/app/build.gradle` (do not edit the Flutter SDK's
  `flutter.groovy`).
- Use the AGP Upgrade Assistant in Android Studio and check Kotlin ↔ AGP
  compatibility (<https://developer.android.com/build/kotlin-support>).
- Rebuild: `./gradlew clean && ./gradlew build`.
- Signing fingerprints for Firebase: `./gradlew signingReport`.

---

## Project status

Work in progress. Main open items (see also `lib/TODO` and `__pocketbase/commandline`):

- Push notification on new pairings (hook written but not registered, see review).
- Player self-registration flow and top-cut calculator.
- Localisation (UI strings are hard-coded in Italian).
- Automated tests (none at the moment).
