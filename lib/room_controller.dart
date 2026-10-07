import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api/generated.dart';
import 'api/transport.dart';
import 'config.dart';

class RoomController extends ChangeNotifier {
  final QitApi api;
  final String code;
  Snapshot? snapshot;
  Object? error;
  bool live = false, busy = false;
  bool _disposed = false, _refreshing = false, _connecting = false;
  int _attempt = 0;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _retry, _poll, _debounce;
  RoomController(this.api, this.code);
  Future<void> start() async {
    try {
      try {
        snapshot = await api.getSnapshot(code: code);
      } on ApiException catch (e) {
        if (e.status != 403) rethrow;
        await api.joinRoom(
          code: code,
          body: JoinRequest(native: !kIsWeb),
        );
        snapshot = await api.getSnapshot(code: code);
      }
      error = null;
      if (_disposed) return;
      notifyListeners();
      _connect();
      _poll = Timer.periodic(const Duration(seconds: 15), (_) => refresh());
    } catch (e) {
      error = e;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_disposed || _refreshing) return;
    _refreshing = true;
    try {
      final next = await api.getSnapshot(code: code);
      if (_disposed) return;
      if (snapshot == null || next.room.revision >= snapshot!.room.revision) {
        snapshot = next;
      }
      error = null;
    } catch (e) {
      error = e;
      if (e is ApiException && [401, 403, 404].contains(e.status)) {
        snapshot = null;
        _poll?.cancel();
        _retry?.cancel();
        _subscription?.cancel();
        _channel?.sink.close();
      }
    } finally {
      _refreshing = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _connect() async {
    if (_disposed ||
        _connecting ||
        snapshot == null ||
        snapshot!.room.status == 'closed') {
      return;
    }
    _connecting = true;
    try {
      final ticket = await api.getEventTicket(code: code);
      if (_disposed) return;
      final base = Uri.base.resolve(Config.apiUrl);
      final uri = base.replace(
        scheme: base.scheme == 'https' ? 'wss' : 'ws',
        path: '${base.path}/rooms/$code/events',
        queryParameters: {'ticket': ticket.ticket},
      );
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      await channel.ready;
      if (_disposed) {
        await channel.sink.close();
        return;
      }
      live = true;
      _attempt = 0;
      notifyListeners();
      _subscription = channel.stream.listen(
        (raw) {
          try {
            final event = RoomEvent.fromJson(
              jsonDecode(raw as String) as Map<String, dynamic>,
            );
            if (event.snapshot != null &&
                (snapshot == null ||
                    event.revision >= snapshot!.room.revision)) {
              snapshot = event.snapshot;
              error = null;
              notifyListeners();
            } else if (event.type == 'playback' ||
                event.revision > (snapshot?.room.revision ?? 0)) {
              // Debounce bursts; always fetch authoritative state, including this guest's votes.
              _debounce ??= Timer(const Duration(milliseconds: 100), () {
                _debounce = null;
                refresh();
              });
            }
          } catch (_) {
            refresh();
          }
        },
        onError: (_) => _reconnect(),
        onDone: _reconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _reconnect();
    } finally {
      _connecting = false;
    }
  }

  void _reconnect() {
    if (_disposed || _retry?.isActive == true) return;
    live = false;
    notifyListeners();
    final seconds = min(30, 1 << min(_attempt++, 5));
    _retry = Timer(Duration(seconds: seconds), () {
      _subscription?.cancel();
      _channel?.sink.close();
      _connect();
      refresh();
    });
  }

  Future<void> act(Future<dynamic> Function() action) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await action();
      await refresh();
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _poll?.cancel();
    _debounce?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
