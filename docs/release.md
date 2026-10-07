# Client release guide

## Configuration and builds

Use Flutter 3.47.6 with its bundled Dart SDK. Android needs Java 17, the Android SDK and the platform packages selected by Flutter/Gradle. iOS needs a macOS machine with full Xcode, the SDKs and the package tooling required by Flutter plugins. `.fvmrc` points to the official stable SDK, replacing the prototype's fork/master pin.

Copy `config.example.json` to an untracked `client-config.json` file containing `API_URL`, `PUBLIC_URL`, `SUPABASE_URL`, and `SUPABASE_ANON_KEY`, with `DEMO_MODE=false`. Build using `--dart-define-from-file=/secure/path/client-config.json`. Only public configuration belongs in this file. Never include Spotify secrets, database URLs, token encryption keys or Supabase service-role keys.

```sh
flutter analyze
flutter test
flutter build web --release --dart-define-from-file=/secure/path/client-config.json
flutter build apk --release --dart-define-from-file=/secure/path/client-config.json
flutter build appbundle --release --dart-define-from-file=/secure/path/client-config.json
flutter build ios --release --no-codesign --dart-define-from-file=/secure/path/client-config.json
```

Production app links require a real HTTPS domain, not the placeholder `qit.example.com`. The web app must be served under that domain with history fallback. Requests and cookies should stay on the same origin, e.g. `https://your-domain/api/v1`. The provided Nginx container forwards that path to a service named `api`, includes WebSocket upgrades, and serves the two domain-association files without redirecting them to the SPA.

The default web build uses JavaScript/CanvasKit. Its secure-storage dependency currently prevents a WebAssembly build; `--wasm` is not a supported target for this release.

## Android app links and signing

The application ID is `app.qit.qit`; keep it consistent in Gradle and `assetlinks.json`, or change both before the first store release. Configure `qitDomain=your-domain` in an untracked Gradle properties file or through the build's project properties. The manifest declares verified HTTPS App Links. Limit domain-association deployment to domains you own.

Replace `web/.well-known/assetlinks.json` with the release signing certificate's SHA-256 fingerprint. For Play App Signing, use the Play-distributed signing certificate, not merely the upload key. Add a debug fingerprint only on a separate test domain. Serve the file as JSON with status 200 and no authentication/redirect.

Release builds are deliberately unsigned until signing is configured. Create an upload keystore, keep it outside the repo, and provide `QIT_KEYSTORE`, `QIT_KEYSTORE_PASSWORD`, `QIT_KEY_ALIAS`, and `QIT_KEY_PASSWORD` to Gradle through the environment. CI builds without these produce unsigned verification artifacts. Never use the debug signing key for publication.

Test a signed installed build using an HTTPS room link opened from another app and a QR scan. Verify a cold launch and an already-running app reach the correct room. Repeat after uninstalling; the link must open the guest website.

## iOS universal links and signing

Use bundle ID `app.qit.qit` consistently, select your Apple team in Xcode and set `QIT_DOMAIN` to your HTTPS domain for each build configuration. `Runner.entitlements` includes Associated Domains and secure-storage keychain access. Replace `APPLE_TEAM_ID` in `web/.well-known/apple-app-site-association` with the actual team ID. Serve this extensionless JSON file directly over HTTPS.

The association includes `/r/*`, `/host`, and `/auth/callback`. `go_router` owns these links. Supabase URI detection is disabled because qIt sends the PKCE code to Go for the server-side exchange, keeping Spotify tokens off the client. The callback must return to the same app/browser that initiated login so it can retrieve its secure-storage verifier and state. Verify cold and warm returns on both native platforms, denied consent, expired state, and browser fallback. Native-to-browser fallback cannot complete a native-started login; the screen asks the host to return to the initiating app or start again. After a successful exchange the SDK persists/refreshes the Supabase session and qIt opens `/host`.

Use Xcode's archive/distribution workflow or a configured signing CI job for TestFlight/App Store builds. An unsigned build verifies compilation only. Test universal links on a signed physical-device build and verify web fallback with the app uninstalled. Safari/user link preferences can intentionally keep a link in the browser; the browser flow remains fully functional.

## Store and deployment handoff

Prepare app descriptions, screenshots, a support URL and an accurate privacy policy identifying Supabase authentication, Spotify account connection, room activity storage and account deletion. Complete the stores' privacy disclosures based on the actual deployment. The application includes account deletion and Spotify disconnect. Push notifications, paid requests, ads and background playback are not part of this release.

Verify keyboard/screen-reader navigation, large text, low connectivity, refresh/reconnect, optional nicknames, QR readability, and the live Spotify smoke test in the backend runbook. App icons are generated by `tool/generate_icons.swift` and checked in.

This build does not publish the website, request Spotify quota approval, or submit store releases. Those steps require your hosting/domain/provider accounts and signing credentials.
