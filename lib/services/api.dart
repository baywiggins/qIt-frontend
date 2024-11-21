import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qit/services/secure_storage.dart';
import 'package:uuid/uuid.dart';

class Api {
  static final String baseURL = dotenv.get("API_URL");

  static Future<bool> checkAndUpdateAuthStatus() async {
    String? token = await SecureStorage.getItem("jwt_token");
    // ignore: unrelated_type_equality_checks
    if (token == null) {
      SecureStorage.saveNewItem("is_authorized", "false");
      return false;
    }

    var headers = {
      'Authorization': token,
    };

    final resp = await http.get(Uri.parse("$baseURL/account/test-auth"),
        headers: headers);
    bool status = resp.statusCode == 200;

    if (!status) {
      SecureStorage.saveNewItem("is_authorized", "false");
    } else {
      SecureStorage.saveNewItem("is_authorized", "true");
    }

    return status;
  }

  static Future<String> getAuthURL() async {
    String? token = await SecureStorage.getItem("jwt_token");
    String? state = await SecureStorage.getItem("state");
    if (token == null || state == null) {
      return "";
    }
    final resp = await http
        .get(Uri.parse("$baseURL/spotify/auth?state=$state"), headers: {
      "Authorization": token,
    });
    Map<String, dynamic> data = jsonDecode(resp.body);

    return data["auth_url"];
  }

  static Future<bool> postSignIn(String username, String password) async {
    // Create the request body with username, password, and state
    var body = json.encode({
      "username": username,
      "password": password,
      "state": "",
    });

    try {
      // Make the POST request, include Content-Type header and JSON body
      final resp = await http.post(
        Uri.parse("$baseURL/account/login"),
        headers: {
          "Content-Type": "application/json", // Set the correct content type
        },
        body: body, // Pass the body as a JSON-encoded string
      );

      // Check if the response status code is OK (200)
      bool status = resp.statusCode == 200;

      if (!status) {
        // If the status is not 200, log the error and return false
        print("Request failed with status: ${resp.statusCode}");
        return false;
      }

      // Parse the JSON response body
      Map<String, dynamic> data = jsonDecode(resp.body);

      // // Save the token and state in secure storage
      await SecureStorage.saveNewItem("jwt_token", data["token"]);

      // // Call the function to check and update authentication status
      checkAndUpdateAuthStatus();

      return true;
    } catch (e) {
      // Handle any errors such as network issues or JSON decoding errors
      print("Error during login: $e");
      return false;
    }
  }

  static Future<bool> postCreateAccount(
      String username, String password) async {
    String state = const Uuid().v4();
    await SecureStorage.saveNewItem("state", state);
    // Create the request body with username, password, and state
    var body = json.encode({
      "username": username,
      "password": password,
      "state": state,
    });

    try {
      // Make the POST request, include Content-Type header and JSON body
      final resp = await http.post(
        Uri.parse("$baseURL/account/create"),
        headers: {
          "Content-Type": "application/json", // Set the correct content type
        },
        body: body, // Pass the body as a JSON-encoded string
      );

      // Check if the response status code is OK (200)
      bool status = resp.statusCode == 200;

      if (!status) {
        // If the status is not 200, log the error and return false
        print("Request failed with status: ${resp.statusCode}");
        return false;
      }

      // Parse the JSON response body
      Map<String, dynamic> data = jsonDecode(resp.body);

      // // Save the token and state in secure storage
      await SecureStorage.saveNewItem("jwt_token", data["token"]);
      await SecureStorage.saveNewItem("state", state);

      // // Call the function to check and update authentication status
      checkAndUpdateAuthStatus();

      return true;
    } catch (e) {
      // Handle any errors such as network issues or JSON decoding errors
      print("Error during account creation: $e");
      return false;
    }
  }
}
