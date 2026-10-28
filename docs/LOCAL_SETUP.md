# Running Tournament Manager locally

This guide starts the **backend** (extended PocketBase) on your machine and runs the
**Flutter app** against it on an emulator or a device.

Backend steps 1–4 were run end to end on a fresh database: build, schema import,
superuser, sign-up, verification, organizer flag, tournament creation. The Docker
variant and the Flutter steps could not be run in that environment, so they are
written from the project configuration.

```
┌─────────────────────────┐      http://<host>:8090       ┌────────────────────────────┐
│ Flutter app             │ ────────────────────────────► │ extended-pocketbase        │
│ (emulator / device)     │                               │ __pocketbase/  (SQLite)    │
└───────────┬─────────────┘                               └────────────────────────────┘
            │ Firebase (cloud project tournament-manager-ee897):
            │ App Check, FCM, Places-key function
            ▼
```

---

## 0. Prerequisites

| Tool | Version | Used for |
|---|---|---|
| Go | ≥ 1.24 (`go.mod` says 1.24.5) | building the backend |
| Docker + Compose | optional | running the backend without Go |
| Flutter | stable channel, Dart ≥ 3.9 (Flutter ≥ 3.35) | the app |
| Android Studio + an emulator | API 33+ recommended | easiest target (see §6) |
| Xcode | optional | iOS simulator / device |

```bash
go version
flutter --version
flutter doctor -v
```

---

## 1. Start the backend

Pick **one** of the two options.

### Option A: Go (recommended for development)

```bash
cd __pocketbase
go run . serve --http=0.0.0.0:8090
```

- On the **first** start it imports `pb_schema.json`: every collection, view and access rule. You should see:
  ```
  [startup] schema imported from pb_schema.json
  Server started at http://0.0.0.0:8090
  ├─ REST API:  http://0.0.0.0:8090/api/
  └─ Dashboard: http://0.0.0.0:8090/_/
  ```
- Data is stored in `__pocketbase/pb_data/`, which is git-ignored. Delete that folder to start again from an empty database.
- `0.0.0.0` makes the server reachable from emulators and phones on your LAN. Use `127.0.0.1` if only the iOS simulator or desktop needs it.
- To use a compiled binary instead: `go build -o extended-pocketbase . && ./extended-pocketbase serve --http=0.0.0.0:8090`.

### Option B: Docker

```bash
cd __pocketbase
docker compose up -d --build
docker compose logs -f pocketbase      # wait for "schema imported from pb_schema.json"
```

This listens on port **8080**, not 8090. Replace the port in the rest of this guide.
Data lives in the `pb_data` Docker volume; `docker compose down -v` wipes it.

### Check it is up

```bash
curl http://localhost:8090/api/health
# {"message":"API is healthy.","code":200,"data":{}}
curl http://localhost:8090/api/myhealthcheck
# {"success":true,"message":"API is healthy","data":{"status":"OK"}}
```

---

## 2. Create the admin (superuser)

```bash
# Option A
cd __pocketbase && go run . superuser upsert admin@example.com 'Admin12345!'
# Option B
docker compose exec pocketbase ./extended-pocketbase superuser upsert admin@example.com 'Admin12345!'
```

Open the dashboard at <http://localhost:8090/_/> and log in with those credentials.

---

## 3. (Optional) Receive emails locally

A local PocketBase has no SMTP server. The verification and password-reset requests
still return `204`, but **no email is delivered**. You have two options:

- **Simplest:** mark users as verified by hand (step 4).
- **Realistic:** run [Mailpit](https://github.com/axllent/mailpit) (`docker run -d -p 8025:8025 -p 1025:1025 axllent/mailpit`), then in the dashboard go to *Settings → Mail settings* → enable SMTP, host `localhost` (or `host.docker.internal` from Docker), port `1025`, no TLS. Read the emails at <http://localhost:8025>.

---

## 4. Create test users

The app only lets you past onboarding once the email is **verified**. The organizer
features (create tournament, manage people, generate rounds) also need the
`organizer` flag. Create at least two users, one organizer and one player:

1. Sign up from the app (step 5), or create the users from the dashboard: *Collections → users → New record*.
2. In the dashboard, open each user, then:
   - tick **verified**;
   - for the organizer account, also tick **organizer**.
3. Save. If the app is already open, log out and back in.

The same thing from the command line, if you prefer:

```bash
B=http://localhost:8090
ADMIN=$(curl -s -X POST $B/api/collections/_superusers/auth-with-password \
  -H 'Content-Type: application/json' \
  -d '{"identity":"admin@example.com","password":"Admin12345!"}' | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')

# create a user
curl -s -X POST $B/api/collections/users/records -H 'Content-Type: application/json' \
  -d '{"email":"org@example.com","password":"Password123!","passwordConfirm":"Password123!","name":"Org","surname":"One","username":"org1"}'

# mark verified + organizer (use the "id" returned above)
curl -s -X PATCH $B/api/collections/users/records/<USER_ID> \
  -H 'Content-Type: application/json' -H "Authorization: $ADMIN" \
  -d '{"verified":true,"organizer":true}'
```

---

## 5. Run the Flutter app

### 5.1 Point the app at your local backend

The app talks to PocketBase through **two** clients, and both must point to your machine:

| Client | Where the URL comes from |
|---|---|
| PocketBase SDK: auth, CRUD, realtime | **hard-coded** in `lib/auth/pocketbase_auth/pocketbase_auth_util.dart` |
| Custom API client: enroll, rounds, close | `--dart-define=POCKETBASE_BASE_URL` (`lib/app_flow/app_config.dart`) |

Until the code reads both from `AppConfig` (code review finding **C-6**), make this
**temporary local edit** and do not commit it:

```dart
// lib/auth/pocketbase_auth/pocketbase_auth_util.dart
final PocketBase pb = PocketBase('http://10.0.2.2:8090');   // ← was 'http://195.201.90.14:8080'
```

Use the same host in both places:

| Target | Host to use |
|---|---|
| Android emulator | `http://10.0.2.2:8090` (the emulator's alias for your computer) |
| iOS simulator | `http://127.0.0.1:8090` |
| Physical device (same Wi-Fi) | `http://<your computer's LAN IP>:8090` (backend started with `--http=0.0.0.0:8090`; allow the port in your firewall) |

> If you forget the edit, the app will log in against the remote server
> `195.201.90.14`, not your local one.

### 5.2 Install and run

```bash
flutter pub get
flutter devices                        # pick an emulator/device id
flutter run -d <device-id> \
  --dart-define=POCKETBASE_BASE_URL=http://10.0.2.2:8090
```

Plain `http://` works in debug: Dart's own HTTP client is not subject to Android's
cleartext policy or iOS ATS.

### 5.3 First run checklist

1. The splash screen appears, then onboarding. Sign up, or sign in with a user from step 4.
2. Accept the notification permission prompt. `initFirebase()` waits for it before the app starts.
3. If the user is not verified you land on *Verify mail*. Tick **verified** in the dashboard (step 4) and continue.
4. As the **organizer**: create a tournament, then go to *People*. Add the player by scanning the QR code on the player's *Profile* page from a second device, or by typing the user ID.
5. Set the tournament to **In Corso** (`ongoing`), then *Rounds → generate*. Enter results in *Pairings*, and see *Rankings*.

---

## 6. Firebase in local development

The app always connects to the cloud Firebase project `tournament-manager-ee897`
(`lib/backend/firebase/firebase_options.dart`). You do not need to run Firebase locally,
but some features need access to that project:

| Feature | What you need |
|---|---|
| App start-up | Nothing. Debug builds use the App Check **debug provider**. |
| Address autocomplete when creating a tournament (callable function `getApiKeyFromSecret`) | The function deployed with the `SECRET_PAK` secret. If App Check enforcement is on for Functions, register your debug token: run the app, copy `Enter this debug secret into the allow list…` from `flutter logs`, and add it under *Firebase console → App Check → Apps → Manage debug tokens*. |
| Push notifications | The FCM token is saved to `device_tokens` at login. Pairing pushes are not wired yet (code review **B-11**). |

To use **your own** Firebase project: run `flutterfire configure`, which regenerates
`firebase_options.dart` and `android/app/google-services.json`. Then deploy the
function from `__firebase/cloud-functions/functions`
(`firebase functions:secrets:set SECRET_PAK` + `firebase deploy --only functions:getApiKeyFromSecret`).

### Platform notes

- **Android emulator:** the recommended target. Use an image *with Google Play services*, or FCM / App Check will fail.
- **iOS:** there is no `GoogleService-Info.plist` (options come from `firebase_options.dart`). `getToken()` for FCM needs APNs, and start-up can fail on a simulator or device without push capability. Prefer Android while developing.
- **Web / desktop:** not supported at the moment. Several services call `dart:io` `Platform.*` (code review **C-11**).

---

## 7. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `schema import failed: … no such table: main.tournament_with_stats` | Old `pb_schema.json` with the views in the wrong order (fixed in this branch). Pull, delete `pb_data/` (or `docker compose down -v`) and start again. |
| `'tournaments' collection found — schema already imported, skipping` | Normal on every start after the first. To apply a newer `pb_schema.json`, wipe `pb_data/`, or import it from *Dashboard → Settings → Import collections*. |
| The app logs in but sees no data, or data from somewhere else | `pocketbase_auth_util.dart` still points to the remote IP (step 5.1). |
| `Connection refused` from the Android emulator | You used `localhost`; use `10.0.2.2`. From a physical device, check the backend listens on `0.0.0.0` and the firewall allows the port. |
| Stuck on *Verify mail* | No SMTP. Tick **verified** in the dashboard (step 4). |
| *Organizer* actions fail with `ORGANIZER_VERIFICATION_FAILED` | Tick **organizer** for the user, and make sure it owns the tournament. |
| Round generation fails with `not in a state that allows round gen` | The tournament must be in state `ongoing` (*In Corso*). |
| Blank screen at start-up | `initFirebase()` is waiting for the notification permission or the FCM token. Accept the prompt, and use an emulator image with Google Play services. |
| Address search returns nothing | `getApiKeyFromSecret` is not reachable (see §6). You can still create the tournament without autocomplete. |
