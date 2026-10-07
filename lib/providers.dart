import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session.dart';
import 'api/transport.dart';
import 'api/generated.dart';
import 'room_controller.dart';

final sessionProvider = ChangeNotifierProvider<HostSession>(
  (ref) => throw UnimplementedError('Override at startup'),
);
final transportProvider = Provider<Transport>((ref) {
  final t = Transport(ref.read(sessionProvider));
  ref.onDispose(t.dispose);
  return t;
});
final apiProvider = Provider<QitApi>(
  (ref) => QitApi(ref.watch(transportProvider).request),
);
final roomProvider = ChangeNotifierProvider.autoDispose
    .family<RoomController, String>(
      (ref, code) => RoomController(ref.watch(apiProvider), code)..start(),
    );
