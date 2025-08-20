import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://script.google.com/macros/s/AKfycbyHT_V8XdoBR3XztPHF7cgCzY5U3XU2XBFZz4CI0eGKG-HRmJj3Ngjxg6ZebRAbION09A/exec";

  static Future<String> getAppStatus() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["status"]; // "running" or "maintenance"
      } else {
        return "running"; // fallback
      }
    } catch (e) {
      return "running"; // fallback
    }
  }
}
