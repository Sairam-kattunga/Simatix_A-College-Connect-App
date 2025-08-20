import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'screens/home_screen.dart';
import 'screens/maintenance_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simatix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StudentHomeScreenWrapper(),
    );
  }
}

// ---------------- Wrapper to manage maintenance check ----------------
class StudentHomeScreenWrapper extends StatefulWidget {
  const StudentHomeScreenWrapper({super.key});

  @override
  State<StudentHomeScreenWrapper> createState() =>
      _StudentHomeScreenWrapperState();
}

class _StudentHomeScreenWrapperState extends State<StudentHomeScreenWrapper> {
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _checkAppStatus(); // initial check
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkAppStatus(); // periodic check every 10 seconds
    });
  }

  Future<void> _checkAppStatus() async {
    final config = await fetchAppStatus();
    if (!mounted) return;

    if (config["status"]?.toLowerCase() == "maintenance") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MaintenanceScreen(
            message: config["message"] ?? "Under maintenance",
            until: config["until"],
            contactEmail: config["note"], // <-- updated parameter name
            forceUpdate: config["force_update"] ?? false,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const StudentHomeScreen();
  }
}

// ---------------- Utility to fetch app status ----------------
Future<Map<String, dynamic>> fetchAppStatus() async {
  const String url =
      "https://script.google.com/macros/s/AKfycbyHT_V8XdoBR3XztPHF7cgCzY5U3XU2XBFZz4CI0eGKG-HRmJj3Ngjxg6ZebRAbION09A/exec";

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (_) {}
  return {"status": "running"}; // fallback
}
