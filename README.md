# qIt

The party picks the music. A shared Flutter app for mobile web, iOS and Android, with account-free song requests and voting. Hosts sign in with Spotify once through Supabase, then control playback and the queue inside qIt. The companion Go backend lives in `baywiggins/qit-backend`.

## Try the local demo

Install Flutter **3.47.6** (also pinned in `.fvmrc`) and start the backend as described in its README.

```sh
flutter pub get
flutter run -d chrome --web-port=8081 \
  --dart-define=API_URL=http://localhost:8080/api/v1 \
  --dart-define=PUBLIC_URL=http://localhost:8081 \
  --dart-define=DEMO_MODE=true
```

Or serve the release build:

```sh
flutter build web --release \
  --dart-define=API_URL=http://localhost:8080/api/v1 \
  --dart-define=PUBLIC_URL=http://localhost:8081 \
  --dart-define=DEMO_MODE=true
python3 tool/serve_web.py
```

Choose **Host a room → Explore as demo host → Create room**. Open the room link in another tab to use the guest experience. The fake catalog has six tracks. No Spotify access or email service is needed in demo mode. Demo host login is memory-only; production uses Supabase's managed session persistence.

## Real authentication

Build with `SUPABASE_URL` and `SUPABASE_ANON_KEY` (a publishable key is supported). These are public client configuration, not the service-role key. Configure the backend against the same project's issuer/signing keys. The host taps **Continue with Spotify**, authorizes Spotify, and returns to `/auth/callback`. The backend exchanges the PKCE code, verifies the managed identity, encrypts Spotify tokens, and returns only the Supabase session. There is no separate email or connect step. Configure the Spotify-only Supabase provider and callback allowlist using the backend deployment guide. Guests never need a Supabase or Spotify account. Native host sessions and guest credentials use platform secure storage; web guest identity uses an HttpOnly room cookie.

`DEMO_MODE` must be false/omitted for production. Native builds also require an absolute HTTPS `API_URL`; the browser may use the default same-origin `/api/v1`. `PUBLIC_URL` is the canonical HTTPS domain for QR codes and app links.

## Verify and regenerate

```sh
flutter analyze
flutter test
python3 tool/generate_api.py api/openapi.json lib/api/generated.dart
dart format lib/api/generated.dart
flutter build web --release
flutter build apk --release
flutter build ios --release --no-codesign
```

To run the service integration test, first run `python3 scripts/client_fixture.py` from the backend while its demo API is running, then run `flutter test --dart-define=QIT_TEST_FIXTURE=/tmp/qit-client-fixture.json` here. This uses real local HTTP/WebSockets and the fake Spotify worker; regenerate the isolated fixture for each run.

The backend's `api/openapi.json` is canonical. Copy it here before regeneration. The generated client includes immutable models and typed HTTP methods; `Transport` supplies managed host auth and room credentials. `RoomController` combines authoritative snapshots, reconnecting WebSockets, debounced invalidations and periodic fallback refreshes.

See [`docs/release.md`](docs/release.md) for hosting, universal/app links, signing and external release checks. The supported targets are web, Android and iOS; old desktop scaffold directories are not part of this release.
