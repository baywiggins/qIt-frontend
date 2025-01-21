import 'dart:convert';

import 'package:qit/services/secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenValidator {
  // Check if the token is expired
  Future<bool> isTokenExpired() async {
    String? tokenExp = await SecureStorage.getItem("token_exp");
    if (tokenExp == null) {
      print("no exp????");
      return true;
    }

    DateTime tokenExpUTC = DateTime.parse(tokenExp);

    print("Token expired at: $tokenExpUTC");
    var now = DateTime.now().toUtc();
    print("Current time is $now");

    if (tokenExpUTC.isAfter(now)) {
      print("token is still valid! Hooray!");
      return false;
    } else {
      print("token is expired >:-(");
      return true;
    }

    // return tokenExpUTC.isBefore(DateTime.now().toUtc());
  }

  // Check if the refresh token is invalid
  Future<bool> isRefreshTokenInvalid(String baseURL) async {
    // Get info from secure storage
    String? refreshToken = await SecureStorage.getItem("refresh_token");
    String? user = await SecureStorage.getItem("user_id");
    String? t = await SecureStorage.getItem("jwt_token");
    if (user == null || refreshToken == null || t == null) {
      return true;
    }

    print("current token is: $t");
    print("attempting to refresh that jawn");
    // Create headers and body
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'refresh_token': refreshToken, 'user_id': user});
    // Make request
    final refreshResponse = await http.post(
      Uri.parse("$baseURL/account/refresh-token"),
      headers: headers,
      body: body,
    );

    if (refreshResponse.statusCode != 200) {
      return true;
    }

    Map<String, dynamic> data = jsonDecode(refreshResponse.body);

    print("huge W! new token is ${data["token"]}");
    // Save the token and uuid in secure storage
    await SecureStorage.saveNewItem("jwt_token", data["token"]);
    await SecureStorage.saveNewItem("user_id", data["uuid"]);
    await SecureStorage.saveNewItem("token_exp", data["token_exp"]);

    return false;
  }
}
