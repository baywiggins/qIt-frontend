import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'config.dart';
import 'api/generated.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureAuthStorage extends LocalStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() => storage.read(key: 'qit.supabase.session');
  @override
  Future<bool> hasAccessToken() async => await accessToken() != null;
  @override
  Future<void> persistSession(String persistSessionString) =>
      storage.write(key: 'qit.supabase.session', value: persistSessionString);
  @override
  Future<void> removePersistedSession() =>
      storage.delete(key: 'qit.supabase.session');
}

class HostSession extends ChangeNotifier {
  final SupabaseClient? supabase;
  String? demoToken;
  StreamSubscription<AuthState>? _subscription;
  HostSession(this.supabase) {
    _subscription = supabase?.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }
  bool get signedIn =>
      demoToken != null || supabase?.auth.currentSession != null;
  Future<String?> token() async {
    if (demoToken != null) return demoToken;
    final s = supabase?.auth.currentSession;
    if (s != null && s.isExpired) {
      return (await supabase!.auth.refreshSession()).session?.accessToken;
    }
    return s?.accessToken;
  }

  void useDemo(String value) {
    demoToken = value;
    notifyListeners();
  }

  final _loginStorage = const FlutterSecureStorage();
  Future<Uri> spotifyLoginUrl() async {
    if (supabase == null) throw 'Spotify sign-in is not configured yet.';
    String nonce() => base64UrlEncode(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    ).replaceAll('=', '');
    final verifier = nonce(), state = nonce();
    await _loginStorage.write(
      key: 'qit.spotify.login',
      value: jsonEncode({
        'verifier': verifier,
        'state': state,
        'started_at': DateTime.now().millisecondsSinceEpoch,
      }),
    );
    final challenge = base64UrlEncode(
      sha256.convert(utf8.encode(verifier)).bytes,
    ).replaceAll('=', '');
    final callback = Uri.parse(
      '${Config.publicUrl}/auth/callback',
    ).replace(queryParameters: {'state': state});
    return Uri.parse('${Config.supabaseUrl}/auth/v1/authorize').replace(
      queryParameters: {
        'provider': 'spotify',
        'scopes': 'user-read-playback-state,user-modify-playback-state',
        'redirect_to': callback.toString(),
        'code_challenge': challenge,
        'code_challenge_method': 's256',
      },
    );
  }

  Future<void> completeSpotifyLogin(Uri callback, QitApi api) async {
    final raw = await _loginStorage.read(key: 'qit.spotify.login');
    if (raw == null) {
      throw 'Return to the app or browser where you started sign-in, then try again.';
    }
    final pending = jsonDecode(raw) as Map<String, dynamic>;
    if (pending['state'] != callback.queryParameters['state'] ||
        DateTime.now().millisecondsSinceEpoch <
            (pending['started_at'] as int) ||
        DateTime.now().millisecondsSinceEpoch - (pending['started_at'] as int) >
            600000) {
      throw 'This sign-in has expired. Start again.';
    }
    await _loginStorage.delete(key: 'qit.spotify.login');
    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw 'Spotify sign-in was cancelled or could not finish. Try again.';
    }
    final result = await api.exchangeSpotifyLogin(
      body: SpotifyLoginRequest(
        code: code,
        verifier: pending['verifier'] as String,
      ),
    );
    await supabase!.auth.setSession(result.refreshToken);
    notifyListeners();
  }

  Future<void> signOut() async {
    demoToken = null;
    await supabase?.auth.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
