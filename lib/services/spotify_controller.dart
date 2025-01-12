import 'dart:convert';

import 'package:qit/services/secure_storage.dart';
import 'package:http/http.dart' as http;

class SpotifyController {
  final String baseURL;

  // Constructor
  SpotifyController(this.baseURL);

  Future<(String, String, String)> getInfoFromSecureStorage() async {
    try {
      String? token = await SecureStorage.getItem("jwt_token");
      String? state = await SecureStorage.getItem("state");
      String? user = await SecureStorage.getItem("user_id");

      if (token == null || state == null || user == null) {
        return ("", "", "");
      }

      return (token, state, user);
    } catch (e) {
      // Log or handle errors appropriately
      print("Error retrieving secure storage data: $e");
      return ("", "", "");
    }
  }

  Future<void> pause() async {
    try {
      var (token, state, user) = await getInfoFromSecureStorage();

      if (token.isEmpty || state.isEmpty || user.isEmpty) {
        print("Missing credentials.");
        return;
      }

      var headers = {
        'Authorization': token,
        'uuid': user,
      };

      final response = await http.get(
        Uri.parse("$baseURL/spotify/pause"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print("Failed to pause playback: ${response.statusCode}");
      }
    } catch (e) {
      // Log or handle network or other errors
      print("Error during pause operation: $e");
    }
  }

  Future<void> play() async {
    try {
      var (token, state, user) = await getInfoFromSecureStorage();

      if (token.isEmpty || state.isEmpty || user.isEmpty) {
        print("Missing credentials.");
        return;
      }

      var headers = {
        'Authorization': token,
        'uuid': user,
      };

      final response = await http.get(
        Uri.parse("$baseURL/spotify/play"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print("Failed to start playback: ${response.statusCode}");
      }
    } catch (e) {
      // Log or handle network or other errors
      print("Error during play operation: $e");
    }
  }

  Future<bool> isPlaying() async {
    try {
      var (token, state, user) = await getInfoFromSecureStorage();

      if (token.isEmpty || state.isEmpty || user.isEmpty) {
        print("Missing credentials.");
        return false;
      }

      var headers = {
        'Authorization': token,
        'uuid': user,
      };

      final response = await http.get(
        Uri.parse("$baseURL/spotify/playback-state"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print("Failed to fetch playback state: ${response.statusCode}");
        return false;
      }

      Map<String, dynamic> data = jsonDecode(response.body);

      return data["is_playing"] ?? false;
    } catch (e) {
      // Log or handle network or other errors
      print("Error checking playback state: $e");
      return false;
    }
  }
}
