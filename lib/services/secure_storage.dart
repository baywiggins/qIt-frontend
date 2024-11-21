import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> initialize() async {
    String? isAuthorized = await _storage.read(key: "is_authorized");
    // ignore: unrelated_type_equality_checks
    if (isAuthorized == false || isAuthorized == null) {
      await _storage.write(key: "is_authorized", value: "true");
    }
  }

  static Future<void> saveNewItem(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getItem(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteItem(String key) async {
    await _storage.delete(key: key);
  }
}
