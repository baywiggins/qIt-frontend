import 'package:flutter_test/flutter_test.dart';
import 'package:qit/api/generated.dart';

void main() {
  test(
    'generated client preserves optional fields and escapes room paths',
    () async {
      String? path;
      Map<String, dynamic>? sentBody;
      final api = QitApi((method, p, {body, query}) async {
        path = p;
        sentBody = body;
        return {'ok': true};
      });
      await api.updateSettings(
        code: 'A/B',
        body: const SettingsRequest(paused: true),
      );
      expect(path, '/rooms/A%2FB/settings');
      expect(sentBody, {'paused': true});
      expect(const JoinRequest().toJson(), {'nickname': '', 'native': false});
    },
  );
}
