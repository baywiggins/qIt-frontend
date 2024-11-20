import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Api {
  final String baseURL = dotenv.get("API_URL");

  Future<String> getAuthURL() async {
    final resp = await http.get(Uri.parse(baseURL + "/spotify/auth"));
    Map<String, dynamic> data = jsonDecode(resp.body);

    return data["auth_url"];
  }
}
