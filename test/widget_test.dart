import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qit/main.dart';
import 'package:qit/providers.dart';
import 'package:qit/session.dart';

void main() {
  testWidgets(
    'guest landing renders on a small phone without requiring login',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionProvider.overrideWith((ref) => HostSession(null))],
          child: const QitApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Good music.\nA group decision.'), findsOneWidget);
      expect(find.byKey(const Key('room-code')), findsOneWidget);
      // Framework reports any overflow with its originating widget.
      await tester.enterText(find.byKey(const Key('room-code')), 'BAD');
      await tester.ensureVisible(find.byKey(const Key('join-room')));
      await tester.tap(find.byKey(const Key('join-room')));
      await tester.pumpAndSettle();
      expect(find.text('Enter the eight-character room code.'), findsOneWidget);
    },
  );
}
