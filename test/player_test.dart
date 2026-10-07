import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qit/api/generated.dart';
import 'package:qit/playback_panel.dart';
import 'package:qit/providers.dart';
import 'package:qit/room_controller.dart';
import 'package:qit/screens.dart';
import 'package:qit/session.dart';
import 'package:qit/ui.dart';

const track = Track(
  id: 'track',
  uri: 'spotify:track:track',
  name: 'Test song',
  artists: 'Test artist',
  imageUrl: '',
  spotifyUrl: '',
  durationMs: 210000,
  explicit: false,
  playable: true,
);
PlaybackSnapshot sample({
  required DateTime at,
  bool playing = true,
  int progress = 42000,
  String status = 'ready',
}) => PlaybackSnapshot(
  current: track,
  queue: [],
  fetchedAt: at.toIso8601String(),
  progressMs: progress,
  isPlaying: playing,
  device: const PlaybackDevice(
    id: 'speaker',
    name: 'Party speaker',
    type: 'Speaker',
    isActive: true,
    isRestricted: false,
    supportsVolume: true,
    volumePercent: 60,
  ),
  disallowed: [],
  status: status,
  message: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'progress advances only while playing and never infers the next track',
    () {
      final at = DateTime.utc(2026, 10, 5);
      expect(
        playbackPosition(sample(at: at), at.add(const Duration(seconds: 10))),
        52000,
      );
      expect(
        playbackPosition(
          sample(at: at, playing: false),
          at.add(const Duration(seconds: 10)),
        ),
        42000,
      );
      expect(
        playbackPosition(
          sample(at: at, status: 'unavailable'),
          at.add(const Duration(seconds: 10)),
        ),
        42000,
      );
      expect(
        playbackPosition(sample(at: at), at.add(const Duration(minutes: 5))),
        87000,
      );
      expect(
        playbackPosition(
          sample(at: at, progress: 209000),
          at.add(const Duration(seconds: 10)),
        ),
        210000,
      );
      expect(
        playbackFresh(sample(at: at), at.add(const Duration(seconds: 45))),
        isFalse,
      );
    },
  );
  test(
    'callback rejects missing, wrong, expired and future login state before code exchange',
    () async {
      final session = HostSession(null);
      addTearDown(session.dispose);
      var exchanges = 0;
      final api = QitApi((method, path, {body, query}) async {
        exchanges++;
        return {};
      });
      final callback = Uri.parse(
        'https://qit.example/auth/callback?state=expected&code=valid-code',
      );
      for (final pending in <Map<String, dynamic>?>[
        null,
        {
          'state': 'wrong',
          'verifier': 'secret',
          'started_at': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'state': 'expected',
          'verifier': 'secret',
          'started_at': DateTime.now()
              .subtract(const Duration(minutes: 11))
              .millisecondsSinceEpoch,
        },
        {
          'state': 'expected',
          'verifier': 'secret',
          'started_at': DateTime.now()
              .add(const Duration(minutes: 1))
              .millisecondsSinceEpoch,
        },
      ]) {
        FlutterSecureStorage.setMockInitialValues({
          if (pending != null) 'qit.spotify.login': jsonEncode(pending),
        });
        await expectLater(
          session.completeSpotifyLogin(callback, api),
          throwsA(isA<String>()),
        );
      }
      expect(exchanges, 0);
    },
  );
  testWidgets('Spotify is the only host sign-in form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => HostSession(null))],
        child: MaterialApp(theme: qitTheme(), home: const LoginPage()),
      ),
    );
    expect(find.text('Continue with Spotify'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
  for (final host in [true, false]) {
    testWidgets(
      '${host ? 'host controls' : 'guest read-only progress'} fit a small phone',
      (tester) async {
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = QitApi(
          (method, path, {body, query}) async =>
              throw 'Unexpected network call',
        );
        final controller = RoomController(api, 'TESTCODE');
        controller.snapshot = Snapshot(
          room: const Room(
            id: 'room',
            code: 'TESTCODE',
            name: 'Party',
            threshold: 3,
            paused: false,
            status: 'open',
            revision: 1,
            createdAt: '',
            expiresAt: '',
          ),
          isHost: host,
          members: [],
          suggestions: [],
          playback: sample(at: DateTime.now()),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [apiProvider.overrideWithValue(api)],
            child: MaterialApp(
              theme: qitTheme(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: PlaybackPanel(controller: controller),
                ),
              ),
            ),
          ),
        );
        expect(find.text('Test song'), findsOneWidget);
        expect(
          find.byTooltip('Next song'),
          host ? findsOneWidget : findsNothing,
        );
        expect(
          find.byTooltip('Replay current song'),
          host ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('playback-seek')),
          host ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }
}
