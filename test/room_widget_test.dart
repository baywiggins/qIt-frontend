import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qit/api/generated.dart';
import 'package:qit/providers.dart';
import 'package:qit/room_controller.dart';
import 'package:qit/room_screen.dart';
import 'package:qit/ui.dart';

class PreviewRoom extends RoomController {
  PreviewRoom(super.api, super.code, Snapshot state) {
    snapshot = state;
    live = true;
  }
  @override
  Future<void> refresh() async {}
}

void main() {
  testWidgets('phone guest can withdraw a vote and share a QR invite', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final calls = <String>[];
    final api = QitApi((method, path, {body, query}) async {
      calls.add('$method $path');
      return {'ok': true};
    });
    final snapshot = Snapshot.fromJson({
      'room': {
        'id': 'room',
        'code': 'ABCDEFGH',
        'name': 'A very long party name with friends',
        'threshold': 3,
        'paused': false,
        'status': 'open',
        'revision': 4,
      },
      'member': {'id': 'guest', 'nickname': 'Jubilant Mango', 'blocked': false},
      'is_host': false,
      'members': [],
      'suggestions': [
        {
          'id': 'song',
          'nickname': 'Jubilant Mango',
          'status': 'pending',
          'votes': 1,
          'my_vote': true,
          'delivery_status': 'none',
          'delivery_reason': '',
          'track': {
            'id': 'track',
            'name': 'A very long song title for narrow phones',
            'artists': 'A band with a rather long name',
            'playable': true,
          },
        },
      ],
      'playback': {
        'queue': [],
        'status': 'ready',
        'message': '',
        'fetched_at': DateTime.now().toUtc().toIso8601String(),
      },
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
          roomProvider(
            'ABCDEFGH',
          ).overrideWith((ref) => PreviewRoom(api, 'ABCDEFGH', snapshot)),
        ],
        child: MaterialApp(
          theme: qitTheme(),
          home: const RoomPage(code: 'ABCDEFGH'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('You’re Jubilant Mango'), findsOneWidget);
    final vote = find.text('Voted');
    await tester.scrollUntilVisible(vote, 250);
    await tester.pumpAndSettle();
    await tester.ensureVisible(vote);
    await tester.pumpAndSettle();
    await tester.tap(vote);
    await tester.pumpAndSettle();
    expect(calls, contains('DELETE /rooms/ABCDEFGH/suggestions/song/vote'));
    await tester.tap(find.byTooltip('Share room'));
    await tester.pumpAndSettle();
    expect(find.text('Scan to join. No account needed.'), findsOneWidget);
    expect(find.text('Copy invite link'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
