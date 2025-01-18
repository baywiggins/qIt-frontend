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

    return tokenExpUTC.isBefore(DateTime.now().toUtc());
  }

  // Check if the refresh token is invalid
  Future<bool> isRefreshTokenInvalid(String baseURL) async {
    // Get info from secure storage
    String? refreshToken = await SecureStorage.getItem("refresh_token");
    String? user = await SecureStorage.getItem("user_id");
    if (user == null || refreshToken == null) {
      return true;
    }

    // Create headers
    var headers = {'refresh_token': refreshToken, 'user_id': user};
    // Make request
    final refreshResponse = await http.get(
      Uri.parse("$baseURL/account/refresh-token"),
      headers: headers,
    );

    int status = refreshResponse.statusCode;
    return false; // Example, return actual logic
  }
}
