import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'providers.dart';
import 'session.dart';
import 'screens.dart';
import 'room_screen.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) usePathUrlStrategy();
  SupabaseClient? supabase;
  if (Config.supabaseUrl.isNotEmpty && Config.supabaseKey.isNotEmpty) {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      publishableKey: Config.supabaseKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: false,
        localStorage: kIsWeb ? null : SecureAuthStorage(),
      ),
    );
    supabase = Supabase.instance.client;
  }
  runApp(
    ProviderScope(
      overrides: [sessionProvider.overrideWith((ref) => HostSession(supabase))],
      child: const QitApp(),
    ),
  );
}

class QitApp extends ConsumerStatefulWidget {
  const QitApp({super.key});
  @override
  ConsumerState<QitApp> createState() => _QitAppState();
}

class _QitAppState extends ConsumerState<QitApp> {
  late final GoRouter router;
  SemanticsHandle? semantics;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) semantics = SemanticsBinding.instance.ensureSemantics();
    final session = ref.read(sessionProvider);
    router = GoRouter(
      refreshListenable: session,
      redirect: (context, state) {
        if ((state.uri.path == '/host' || state.uri.path == '/account') &&
            !session.signedIn) {
          return '/login';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, state) => const LandingPage()),
        GoRoute(path: '/login', builder: (_, state) => const LoginPage()),
        GoRoute(
          path: '/auth/callback',
          builder: (_, state) => SpotifyCallbackPage(uri: state.uri),
        ),
        GoRoute(path: '/host', builder: (_, state) => const HostPage()),
        GoRoute(path: '/account', builder: (_, state) => const AccountPage()),
        GoRoute(
          path: '/r/:code',
          builder: (_, state) =>
              RoomPage(code: state.pathParameters['code']!.toUpperCase()),
        ),
      ],
      errorBuilder: (_, state) => const PageShell(
        child: EmptyState(
          icon: Icons.link_off,
          title: 'This link went offbeat',
          body: 'Head back to qIt and enter a room code.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    semantics?.dispose();
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'qIt — The party picks the music',
    debugShowCheckedModeBanner: false,
    theme: qitTheme(),
    routerConfig: router,
  );
}
