# Code review — Tournament Manager

Scope: the whole repository (`lib/`, `__pocketbase/`, `__firebase/`, build/config).
Every finding cites the file and states the concrete failure. Severity:

- 🔴 **Critical**: security hole or data corruption in normal use
- 🟠 **High**: a feature is broken, or state/sessions are lost
- 🟡 **Medium**: reliability or maintainability problem that will cause bugs
- ⚪ **Low**: hygiene, style, dead code

`go vet ./...` on the backend passes. No Flutter SDK was available while writing
this, so the Dart findings come from reading the code, not from `flutter analyze`.

---

## 1. Security

### 🔴 S-1 Any user can make themselves an organizer
`__pocketbase/pb_schema.json` → `users.updateRule = "id = @request.auth.id"` places no
limit on which fields can change. A user can `PATCH /api/collections/users/records/<own id>`
with `{"organizer": true}`. The custom round and enrollment APIs then trust that flag.

**Fix:** `id = @request.auth.id && @request.body.organizer:isset = false` (do the same
for `verified` and `email`). Grant `organizer` only from a superuser or a dedicated endpoint.

### 🔴 S-2 Enrollment rules bypass the capacity and state checks
`enrollments.createRule` / `updateRule = "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id"`.
A player can create their own enrollment with `listKind = "registered"`, or update it from
`waiting` to `registered`, straight through the REST API. That skips everything
`/api/tournamentManager/enroll` checks: capacity, tournament state, list order.

**Fix:** set create and delete to `null` (only the custom API writes them). Keep update
only for the decklist fields, for example `... && @request.body.listKind:isset = false && @request.body.id_user:isset = false && @request.body.id_tournament:isset = false`.

### 🔴 S-3 Tournament owners can write tournament-engine fields directly
`tournaments.updateRule = "id_owner = @request.auth.id"` lets the owner set `state`,
`id_winner`, `lastUpdated_*` and even `id_owner` without the server-side checks. The same
applies to `rounds` / `pairings` create/update/delete. Also `tournaments.createRule` does
not require `@request.auth.organizer = true`, so any user can create tournaments.
The app itself calls `TournamentsRecord.setState` / `setWinnerUserId` from the client
(`lib/backend/schema/tournaments_record.dart`), so the state machine is enforced only in
the UI.

### 🔴 S-4 The Google Places and Algolia keys are given to anyone
`__firebase/cloud-functions/functions/src/getApiKeyFromSecret.ts` and `algoliaApiKeys.ts`
return the secret without checking `request.auth` or enforcing App Check
(`enforceAppCheck: true`). `getAlgoliaApiWKeyFromSecret` looks like a **write** key. Even
with checks, the client ends up holding the raw Places key
(`lib/app_flow/services/PlacesApiManagerService.dart`).

**Fix:** proxy the Places calls server side (or use a key restricted to the app's
package/SHA and bundle ID). Remove the Algolia functions if they are unused.

### 🟠 S-5 Backend over plain HTTP to a hard-coded IP
`lib/auth/pocketbase_auth/pocketbase_auth_util.dart`: `PocketBase('http://195.201.90.14:8080')`.
The bearer token, passwords and personal data travel unencrypted. `AppConfig` already
documents that HTTPS is required, but this client does not use it (see C-6).

### 🟠 S-6 User emails are public, and the users list rule leaks more than intended
- `createAccountWithEmail` sends `'emailVisibility': true`, so every email is returned to any user who can read the record.
- `users.listRule/viewRule` contain `@collection.enrollments.id_tournament ?~ @collection.enrollments.id_tournament`, which is always true. In effect, anyone with any enrollment can list everyone with any enrollment.

### 🟡 S-7 User input is concatenated into PocketBase filters
For example `tournament_people_model.dart:89-99`, where the search box text goes inside
`'name ~ "$_currentFilter"'`, plus `DeviceTokenService`, `tournament_finder_model.dart`
and others. A `"` in the search breaks the query and lets the user change the filter.
**Fix:** `pb.filter('name ~ {:q}', {'q': text})`.

### ⚪ S-8 Committed artifacts
- `__pocketbase/pocketbase_0.26.6_linux_amd64.zip` is an 11 MB binary in git, and it does not match `go.mod` (v0.29.0).
- `android/app/google-services.json` is committed. Not a secret by itself, but every API key in it must be restricted in the Google Cloud console.
- `lib/TODO` contains debug keystore fingerprints and local paths.

---

## 2. Backend (Go / PocketBase) correctness

### 🔴 B-1 New enrollments are inserted with the user and tournament IDs swapped
`internals/apis/apis_people.go`, `executeDBEnrollment`:
```sql
INSERT INTO enrollments (id_user, id_tournament, listKind, ...)
SELECT {:id_tournament}, {:id_user}, {:listKind}, ...
```
The column order and the value order do not match, so every new enrollment is stored with
`id_user = <tournament id>` and `id_tournament = <user id>`. SQLite has no FK constraint
here, so the insert succeeds and the data is silently corrupted. The capacity
sub-query, `WHERE id_tournament = {:id_tournament}`, then counts the wrong rows.

### 🟠 B-2 Moving a player to the waiting list is always a SQL syntax error
Same function, the "else" `UPDATE` ends with a stray `)` after
`AND id_tournament = {:id_tournament}`.

### 🟠 B-3 Raw SQL skips PocketBase hooks, realtime and validation
Enrollments use `txApp.DB().NewQuery(...)`. Round deletion uses `txApp.DB().Delete(...)`
on `pairings`, `rankings` and `rounds`. As a result:
- `OnRecordAfter*` hooks (`hooks.go`) never fire. This is why the code has to bump `lastUpdated_enrollments` by hand, and why `lastUpdated_rounds` is **not** bumped when a round is deleted.
- Realtime subscribers get no event.
- Field validation (select values, relation existence) is skipped.

**Fix:** use `core.NewRecord` + `txApp.Save` / `txApp.Delete`, and keep the capacity check
inside the same transaction.

### 🟠 B-4 `app` is used inside `RunInTransaction`
`executeDBEnrollment` / `executeDBEnrollmentDeletion` call `app.FindCollectionByNameOrId`
and `app.FindFirstRecordByFilter` inside the transaction callback. The PocketBase
documentation warns that this can deadlock, or read outside the transaction. Use `txApp`.
The same function also sets a date field to `dbx.NewExp("datetime('now')")` through
`Record.Set`. Records do not evaluate expressions, so use `types.NowDateTime()`.

### 🟠 B-5 Wrong eligibility results in `gatherUserDetailsForEnrollment`
For the `waiting` and `preregistered` cases, `Eligible = false` is set and then
unconditionally overwritten by `Eligible = true`. The UI therefore says "eligible" for
moves the enroll endpoint will reject.

### 🟡 B-6 `checkUserElegibilityForDeletion` wraps the wrong error
It returns `fmt.Errorf("...: %w", err)` where `err` is the earlier, nil collection error,
not `err2`. A "not found" therefore becomes `failed to check user enrollment: %!w(<nil>)`.

### 🟠 B-7 Round-consistency checks are no-ops
`ValidateRoundConsistency` (`apis_round.go`) returns an error only when a *round* already
exists. When rankings or pairings for that round index already exist (`err == nil`), it
falls through and returns success.

### 🟠 B-8 Swiss pairing algorithm (`PairClusterWithRematchHandling`)
- `pairings` starts with the leftover pairings, but the rematch loop indexes it as if it held only `topHalf[i]`/`bottomHalf[i]` pairings. As soon as a leftover is paired, the swaps act on the wrong pairs.
- Unresolved rematches are removed with `append(pairings[:i], pairings[i+1:]...)` while looping over the pre-computed `rematchIndices`. Every later index shifts, so the wrong pairing gets removed.
- `cluster = append(cluster[:i], cluster[i+1:]...)` and the swaps on `bottomHalf[j].UserId` mutate the caller's slice.
- Leftovers are rebuilt as `PlayerData{UserId: ...}`, which loses points and tie-breakers.
- If leftovers remain after the last cluster, the whole round fails ("lefthover remained"). There is no fallback that accepts a rematch, so an organizer can get stuck in a small tournament.

A standard approach (Dutch/Monrad with backtracking, or a minimum-weight perfect
matching) with unit tests is strongly recommended. This is the core of the product and
currently has **no tests**.

### 🟡 B-9 Top-cut byes are random
`CreateByePairingIfNeeded` gives top-cut byes to random players. Usually the top seeds get
the byes.

### 🟡 B-10 Validation runs outside the write transaction (TOCTOU)
Round index, capacity, state and ownership are validated before `RunInTransaction`. Two
concurrent `generateRound` calls can both pass validation. Move the checks into the
transaction, or add a unique index on `rounds(id_tournament, roundIndex)`.

### 🟠 B-11 Push-notification hook is dead and wrong
`internals/hooks/hooks_push.go`:
- `SetupPairingsCollectionHooks` is never registered in `main.go`.
- Every field is read from `"id_tournament"` (player IDs, names, round, table), so the guard is never satisfied with real data.
- `CreateNotificationRecord` builds `notification` but saves `record`, the pairing. The collection is named `notifications` in code and `notification_logs` in the schema.
- The URL has a double slash (`...vercel.app/` + `/send-notification`), the call has no auth to the Vercel service, `http.DefaultClient` has no timeout, and the function reports `Success: true` whatever the HTTP status.
- Network I/O runs synchronously inside an after-create hook. Use a goroutine or a queue.

### 🟡 B-12 Schema has two sources of truth
`pb_schema.json` is imported on first boot, while `pb_migrations/` holds a partial history.
`rounds`, `pairings` and `rankings` have no "created" migration. Pick one (preferably
migrations, versioned with the code).

### ⚪ B-13 Backend hygiene
- Large blocks of copy-pasted code: the three identical hook triples in `hooks.go`; the repeated `ErrorResponse{...}` and log lines. Each function logs `START`/`END`/`ERROR` with the same message, so errors carry no cause.
- Misleading comments, for example "take the last player in ranking" next to a query sorted by `-points` (that returns the first), and "Fisher-Yates with crypto/rand for reproducibility".
- `validate:"required"` struct tags do nothing, because no validator runs.
- Numbers from views are read with `GetString` + `strings.Trim("\"")` + `Atoi`. That is a sign the view columns are typed as JSON. Cast them in SQL instead.
- `Caddyfile` is still `your-domain.com`. `docker-compose` exposes `8080` publicly as well as behind Caddy.

---

## 3. Flutter app correctness

### 🟠 C-1 Rotated auth tokens are never saved
`PocketbaseAuthManager.signInWithToken` calls `authRefresh()`, which returns a **new**
token, and stores it only in memory. Secure storage keeps the original login token, so the
user is logged out when that token expires, even if they use the app daily.

**Fix:** use `AsyncAuthStore` with `save: (data) => secureStorage.write(...)`, so every
change is saved.

### 🟠 C-2 Sign-out removes the device token after clearing auth
`signOut()` calls `_pb.authStore.clear()` **before** `removeDeviceToken()`.
`removeDeviceToken` needs `authStore.record?.id` and an authenticated request, so it
always returns early. The FCM tokens stay linked to the old user, who keeps receiving
pushes on a shared device. `refreshUser()` has a related crash: it saves the token with
a `null` record and then does `authStore.record?.id` + `userId!`.

### 🟠 C-3 Realtime subscriptions are leaked and cancelled globally
In every `*_record.dart`:
- `onCancel` calls `pb.collection(x).unsubscribe()` **with no topic**. That removes *every* subscription on that collection, including the ones still used by other screens.
- `TournamentsRecord.getDocuments` subscribes to `collectionName` **or** `collectionNameExt`, but always unsubscribes `collectionNameExt`.
- The `Future<UnsubscribeFunc>` returned by `subscribe` is ignored. If the stream is cancelled before the subscription completes, it is never removed.
- `StreamController`s are never closed.
- In `getDocuments`, realtime `create` events are appended to the page list without checking sort, filter or page bounds.

**Fix:** keep the `UnsubscribeFunc` and call it in `onCancel`, or use a small repository
class that owns subscriptions.

### 🟠 C-4 Broken user realtime subscription
`pocketbase_user_provider.dart`: `_pb.collection(...).subscribe(...) as StreamSubscription`.
`subscribe` returns a `Future`, so the cast always throws (and the error is swallowed).
The server-side subscription has already been created, so the handle is lost and never
cancelled. Each call to `pocketbaseUserStream()` adds another one, and
`AuthUserStreamWidget` creates a new stream on **every build**.
`_authStateController` is unused.

### 🟠 C-5 Backend errors are swallowed, and the UI shows stale state
`TournamentsRecord.updateField` / `updateFields` / `updateFiles` (and the equivalents in the
other records) catch every exception and only `logDebug`. The setters change the local
field first. As a result:
- `TournamentModel.setTournamentName` and friends always "succeed": the loader hides and no error is shown.
- The local object and the server disagree until the next realtime event.

The model classes should return a result or throw, and the UI should show the error.

### 🟠 C-6 Two PocketBase base URLs
The SDK client uses the hard-coded IP (S-5), while `PocketbaseApiManagerService` uses
`AppConfig.pocketBaseBaseUrl`. Building with `--dart-define=POCKETBASE_BASE_URL=...`
sends the auth/CRUD traffic and the custom-API traffic to **different servers**. Create
`pb` from `AppConfig`. Better still, drop the separate `http` client and call the custom
endpoints with `pb.send(...)`, which already adds the auth header.

### 🟡 C-7 `PocketbaseApiManagerService.setAuthToken` does nothing
`_defaultHeaders` is a getter that returns a **new** map each time, so
`setAuthToken`/`removeAuthToken` change a temporary object. Callers work around this by
passing `headers: {'Authorization': pb.authStore.token}` on every call.

### 🟡 C-8 Loaders can stay on screen forever, and calls are not awaited
- `TournamentModel` setters call `loaderService.showLoader` / `hideLoader` without `try/finally`.
- `switchTournamentPreIscrizioniEn` calls `switchTournamentWaitingListEn()` without `await`, so the loaders nest.
- `TournamentModel.deleteRound` is an empty stub with a `TODO`, yet it shows a loader.

### 🟡 C-9 Search logic
`initSearchListener`: `text.isNotEmpty || text.length > 2` is the same as `text.isNotEmpty`.
Clearing the search box never triggers a refresh, so the old filter stays applied.

### 🟡 C-10 Double fetch on every tournament event
`TournamentModel.fetchObjectUsingId` subscribes to `tournaments`, and for each event
calls `getDocumentOnce` on `tournament_with_stats`. Every change costs one extra HTTP
round-trip, and a slow response can overwrite a newer one, because nothing cancels or
orders the requests.

### 🟡 C-11 `dart:io` on web
`DeviceTokenService` (`Platform.isAndroid ? 'android' : 'ios'`),
`PlacesApiManagerService.launchMap` and `ExternalAppManagerService` call `Platform.*`
without a `kIsWeb` guard. The web target (`usePathUrlStrategy` in `main.dart`) throws
there. Every non-Android device, including desktop, is stored as `ios`.

### 🟡 C-12 Unsafe parsing in records
`TournamentsRecord._initializeFields` uses `tryParseDate(...)!` for `date`, `created` and
`updated`. A tournament with no date crashes the whole list. `hasCapacity()` does
`_capacity! > 0`. Equality compares `hashCode`s instead of values.

### 🟡 C-13 Router
- A root-level `:tournamentId` route matches **any** single-segment path, so a mistyped route opens a "tournament".
- `debugLogDiagnostics: true` is shipped in release builds.
- `RouteGuard.dashboardGuard` calls `context.safePop()` inside a redirect. Redirects must be side-effect free.
- `logFirebaseEvent('screen_view')` sits in route builders, so it fires on every rebuild rather than once per navigation. Use a `NavigatorObserver` (`FirebaseAnalyticsObserver`).

### 🟡 C-14 Google Places client
- The query string is built by concatenation (`'$baseURL?input=$input&key=...'`), so spaces, `&` and `#` in an address break it. Use `Uri.https(host, path, {...})`.
- `late final _placeApiKey` throws if `initialize` runs twice.
- Errors are logged and an empty list is returned, so the user sees "no results" instead of an error.

### 🟡 C-15 Firebase init blocks startup
`initFirebase()` asks for notification permission and fetches the FCM token **before**
`runApp`. On a slow network, or when the user leaves the permission dialog open, the app
shows a blank screen. The time zone is hard-coded to `Europe/Rome`.

---

## 4. Architecture and maintainability

| # | Issue | Why it matters | Suggestion |
|---|---|---|---|
| A-1 | **No tests.** `test/widget_test.dart` is the default counter test and fails (`MyApp` has no counter). | Pairing and ranking logic are the riskiest parts and have zero coverage, and CI cannot run. | Go unit tests for pairing/bye/ranking, Dart unit tests for the records and models, a widget test per page. |
| A-2 | **No CI** (no GitHub Actions). | Regressions such as B-1 and B-2 ship unnoticed. | `flutter analyze`, `flutter test`, `go vet` and `go test` on every PR. |
| A-3 | **Global mutable singletons.** `pb`, `currentUser` and `currentUserDocument` are top-level variables, and `PocketbaseAuthManager` pulls `GetIt` in its constructor. | Hidden dependencies, untestable code, initialisation-order bugs. | Register `PocketBase`, the auth manager and the repositories in `get_it` (or use Riverpod), and inject them. |
| A-4 | **Records mix model, parser, repository and realtime.** `*Record` classes have mutable `late` fields whose setters write to the server. | Optimistic updates without rollback (C-5); about 300 lines of copy-paste per collection. | Immutable models (`freezed` + `json_serializable`) plus one generic `PocketBaseRepository<T>`. |
| A-5 | **ChangeNotifiers do UI work.** Models show snackbars and loaders directly. | Hard to test, and errors cannot be shown in context. | Expose state (`AsyncValue`/sealed results) and let widgets decide how to present it. |
| A-6 | **FlutterFlow/Firestore leftovers.** `firestore_util.dart`, `mapToFirestore`, `serialization_util.dart` (Firestore), `custom_functions.dart`, the `app_flow_*` naming, `__firebase/backup`, the Firestore rules, and Cloud Functions that sync Firestore counters. | Confusing for a new developer. Several packages are not imported anywhere (`stream_transform`, `crypto`, `google_sign_in`, `sign_in_with_apple`, `share_plus`), and `cloud_firestore` is still pulled in only by the leftover `serialization_util.dart`. | Delete the dead code and run `dart pub deps` / `dependency_validator`. |
| A-7 | **Hard-coded Italian strings** everywhere, while `supportedLocales` lists only `en` and `internationalization.dart` is a stub. | Users on other locales see wrong date and number formatting. Translations cannot be added. | `flutter gen-l10n` with ARB files. |
| A-8 | **Naming conventions.** Service files are PascalCase (`ServiceManager.dart`, `LoaderService.dart`), against Dart's `snake_case` file rule. There are mixed Italian/English identifiers (`switchTournamentPreIscrizioniEn`, `lefthovers`, `Elegibility`, `Sucess`, `RegisterHeathCheckAPI`, `registerdEnrollmentsList`). | Lint noise and poor readability. | Rename. Enable stricter lints (`very_good_analysis` or `lints/recommended` plus `prefer_final_locals`, `unawaited_futures`, `discarded_futures`). |
| A-9 | **Error handling style.** 71 bare `catch (e)` blocks, results returned as `Tuple2<bool,String?>` / `Tuple3`, `bool` flags. | Error details are lost, and callers cannot tell error types apart. | Sealed `Result<T, Failure>` types, and catch `ClientException` specifically. |
| A-10 | **Debug output.** 79 `debugPrint` calls (not stripped in release) next to the `logDebug` helper; `[CREATE]`/`[DISPOSE]` prints in models. | Noise, and personal data in device logs. | Use `logDebug`/`logError` only, or the `logging` package. |
| A-11 | **Dependency hygiene.** `pubspec.yaml` has comments about pending major upgrades (go_router 14→17, flutter_map 7→8, share_plus 10→13), `font_awesome_flutter` is pinned exactly, and `plugin_platform_interface` is a direct dependency. `description` still says "A new Flutter project". | Upgrade debt is growing. | Plan one upgrade at a time, behind tests. |
| A-12 | **Notes committed as code.** `lib/RULES` and `lib/TODO` (Italian notes, a pasted code snippet, a SHA fingerprint) sit inside `lib/`. | Clutter, and they ship with the source package. | Move them to `docs/` or the issue tracker. |
| A-13 | **Material 2.** `useMaterial3: false`, plus a custom FlutterFlow theme. | Material 2 is deprecated in recent Flutter versions. | Migrate to M3 with a `ThemeExtension` for custom tokens. |

---

## 5. What is done well

- A clear **page triad** (container / model / widget) applied consistently. The larger widgets (for example `tournament_detail_widget.dart`) are split into small private widgets.
- Server-side authority for the risky operations (enrollment capacity, round generation, tournament closing) through custom endpoints. The direction is right, but the collection rules have to stop allowing the bypass (S-2, S-3).
- `lastUpdated_*` timestamps on the tournament as a cheap invalidation signal, instead of subscribing to every child collection.
- Rankings and tie-breakers computed in SQL views, which keeps the client thin.
- Recent hardening: `AppConfig` via `--dart-define`, release-only App Check providers, `logDebug` stripped in release, a timeout on session restore, a multi-stage non-root Docker image.

---

## 6. Suggested order of work

1. **S-1, S-2, S-3** (rules) and **B-1, B-2** (enrollment SQL). These are small changes that remove the critical issues.
2. **S-5 / C-6**: HTTPS and a single configured base URL. **C-1 / C-2**: session persistence and sign-out order.
3. **C-3 / C-4**: subscription management, through a repository layer (A-3, A-4).
4. **B-7, B-8, B-10**: harden round generation, with unit tests first (A-1, A-2).
5. Clean-up: dead Firebase/FlutterFlow code, dependencies, l10n, naming (A-6 to A-12).
