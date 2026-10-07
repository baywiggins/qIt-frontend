@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:qit/api/generated.dart';

class LiveClient {
  final String base;
  final String? hostToken;
  String? guestToken;
  final http.Client httpClient = http.Client();
  late final QitApi api = QitApi(request);
  LiveClient(this.base, {this.hostToken});
  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final req = http.Request(
      method,
      Uri.parse('$base$path').replace(queryParameters: query),
    );
    req.headers['Content-Type'] = 'application/json';
    if (hostToken != null) req.headers['Authorization'] = 'Bearer $hostToken';
    if (guestToken != null) req.headers['X-Guest-Token'] = guestToken!;
    if (body != null) req.body = jsonEncode(body);
    final response = await http.Response.fromStream(await httpClient.send(req));
    if (response.statusCode >= 400) {
      throw StateError('${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body);
  }
}

void main() {
  const fixturePath = String.fromEnvironment('QIT_TEST_FIXTURE');
  test(
    'generated Dart client completes account-free voting and durable delivery',
    () async {
      final fixture =
          jsonDecode(File(fixturePath).readAsStringSync())
              as Map<String, dynamic>;
      final base = fixture['api'] as String, code = fixture['code'] as String;
      final host = LiveClient(base, hostToken: fixture['host_token'] as String);
      final guests = List.generate(3, (_) => LiveClient(base));
      addTearDown(() async {
        await host.api.closeRoom(code: code);
        host.httpClient.close();
        for (final guest in guests) {
          guest.httpClient.close();
        }
      });
      expect((await host.api.getHost()).demo, isTrue);
      for (final guest in guests) {
        final joined = await guest.api.joinRoom(
          code: code,
          body: const JoinRequest(native: true),
        );
        guest.guestToken = joined.guestToken;
        expect(joined.member.nickname, contains(' '));
      }
      final first = guests.first.api;
      final resumed = await first.joinRoom(
        code: code,
        body: const JoinRequest(native: true),
      );
      expect(
        resumed.member.id,
        (await first.getSnapshot(code: code)).member!.id,
      );
      final ticket = await first.getEventTicket(code: code);
      final socket = await WebSocket.connect(
        '${base.replaceFirst('http', 'ws')}/rooms/$code/events?ticket=${ticket.ticket}',
      );
      addTearDown(socket.close);
      final events = StreamIterator(
        socket.map(
          (raw) => RoomEvent.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>,
          ),
        ),
      );
      expect(
        await events.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      expect(events.current.snapshot?.member?.id, resumed.member.id);
      final tracks = await first.searchTracks(code: code, q: 'Midnight');
      expect(tracks.single.name, 'Midnight City');
      final requested = await first.suggestTrack(
        code: code,
        body: SuggestionRequest(trackId: tracks.single.id),
      );
      var snapshot = await first.getSnapshot(code: code);
      expect(snapshot.suggestions.single.votes, 1);
      expect(snapshot.suggestions.single.myVote, isTrue);
      await first.removeVote(code: code, suggestion: requested.id);
      expect((await first.getSnapshot(code: code)).suggestions.single.votes, 0);
      await first.addVote(code: code, suggestion: requested.id);
      await Future.wait(
        guests
            .skip(1)
            .map((g) => g.api.addVote(code: code, suggestion: requested.id)),
      );
      final deadline = DateTime.now().add(const Duration(seconds: 8));
      do {
        snapshot = await first.getSnapshot(code: code);
        if (snapshot.suggestions.single.deliveryStatus == 'sent') break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } while (DateTime.now().isBefore(deadline));
      expect(snapshot.suggestions.single.status, 'approved');
      expect(snapshot.suggestions.single.deliveryStatus, 'sent');
      expect(snapshot.suggestions.single.votes, 3);
      final duplicate = await first.suggestTrack(
        code: code,
        body: SuggestionRequest(trackId: tracks.single.id),
      );
      expect(duplicate.id, requested.id);
      expect(
        await events.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      expect(events.current.revision, greaterThan(1));
      await events.cancel();
    },
    skip: fixturePath.isEmpty
        ? 'Run scripts/client_fixture.py and pass QIT_TEST_FIXTURE to enable the local service test.'
        : false,
  );
}
