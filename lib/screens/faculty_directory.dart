import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'faculty_model.dart';

enum SortOption { nameAsc, recent }

class FacultyDirectoryScreen extends StatefulWidget {
  const FacultyDirectoryScreen({super.key});

  @override
  State<FacultyDirectoryScreen> createState() => _FacultyDirectoryScreenState();
}

class _FacultyDirectoryScreenState extends State<FacultyDirectoryScreen> {
  static const String _dataUrl =
      'https://script.google.com/macros/s/AKfycbzkiXuZ5OuF8J82pDopYQyvYRDtXyGZRKDav8UuLbz24ITi23pM4XkGMtwY1U_RIkEy/exec';
  static const String _googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSfP7yEb9BQeXdEI-i0z8gBsOdDfTw5ru-iloKEh8s8buWKdqg/viewform?usp=dialog'; // Replace with your form URL

  final List<Faculty> _all = [];
  bool _loading = true;
  String _search = '';
  SortOption _sort = SortOption.nameAsc;
  Timer? _debounce;
  Faculty? _selectedFaculty;

  @override
  void initState() {
    super.initState();
    _fetchFaculty();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchFaculty() async {
    setState(() => _loading = true);
    try {
      final res =
      await http.get(Uri.parse(_dataUrl)).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(() {
            _all
              ..clear()
              ..addAll(data.map((e) => Faculty.fromJson(e as Map<String, dynamic>)));
            _loading = false;
          });
        } else {
          _showSnack('Unexpected response format');
        }
      } else {
        _showSnack('Failed (${res.statusCode}) — try again');
      }
    } on TimeoutException {
      _showSnack('Request timed out. Check connection.');
    } catch (e) {
      _showSnack('Could not load data');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---- Search + Sort ----
  List<Faculty> get _filteredSorted {
    final q = _search.trim().toLowerCase();
    final filtered = _all.where((f) {
      if (q.isEmpty) return true;
      return f.name.toLowerCase().contains(q) ||
          f.department.toLowerCase().contains(q) ||
          f.phone.toLowerCase().contains(q);
    }).toList();

    if (_sort == SortOption.nameAsc) {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  // ---- Actions ----
  String _cleanNumber(String input) => input.replaceAll(RegExp(r'[^0-9+]'), '');

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: _cleanNumber(number));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
    else _showSnack('Could not open dialer');
  }

  Future<void> _whatsapp(String number) async {
    final n = _cleanNumber(number);
    final uri = Uri.parse('https://wa.me/$n?text=Hello%20Professor');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('WhatsApp not available');
    }
  }

  Future<void> _openForm() async {
    final uri = Uri.parse(_googleFormUrl);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    else _showSnack('Could not open form');
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredSorted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Directory'),
        actions: [
          IconButton(
            tooltip: 'Add Faculty',
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.green),
            onPressed: _openForm,
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            initialValue: _sort,
            onSelected: (opt) => setState(() => _sort = opt),
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Sort by Name'),
              ),
              PopupMenuItem(
                value: SortOption.recent,
                child: Text('Sort by Recently Added'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search name / department / phone',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _search = v);
                    });
                  },
                  textInputAction: TextInputAction.search,
                ),
              ),

              // Faculty List
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: _fetchFaculty,
                  child: items.isEmpty
                      ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No faculty found')),
                    ],
                  )
                      : ListView.builder(
                    itemCount: items.length,
                    // Inside ListView.builder
                    itemBuilder: (context, i) {
                      final f = items[i];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFaculty = f),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Accent Strip
                                Container(
                                  width: 6,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.indigoAccent, // you can vary by department
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Avatar + Info
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Icon(
                                    Icons.person, // Or a more specific icon
                                    size: 30,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        f.name,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        f.department,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        f.phone,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Call',
                                      icon: const Icon(Icons.call),
                                      color: Colors.green.shade700,
                                      onPressed: () => _call(f.phone),
                                    ),
                                    IconButton(
                                      tooltip: 'WhatsApp',
                                      icon: const Icon(Icons.chat_bubble),
                                      color: Colors.teal.shade700,
                                      onPressed: () => _whatsapp(f.phone),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    },

                  ),
                ),
              ),
            ],
          ),

          // Dimmed overlay + Selected Faculty Card
          // Dimmed overlay + Selected Faculty Card
          if (_selectedFaculty != null) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFaculty = null),
                child: Container(
                  color: Colors.black.withOpacity(0.6), // More premium dim
                ),
              ),
            ),
            Center(
              child: Card(
                elevation: 16,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade100],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name Header
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.indigo.shade100,
                        child: Icon(
                          Icons.person, // Or a more specific icon
                          size: 40, // Slightly larger for the detail view
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFaculty!.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFaculty!.department,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 24, thickness: 1.2),

                      // Contact Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text(
                            _selectedFaculty!.phone,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.blueAccent),
                            tooltip: 'Copy Number',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _selectedFaculty!.phone));
                              _showSnack('Number copied to clipboard');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _call(_selectedFaculty!.phone),
                              icon: const Icon(Icons.call),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _whatsapp(_selectedFaculty!.phone),
                              icon: const Icon(Icons.chat_bubble),
                              label: const Text('Msg'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _selectedFaculty = null),
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

        ],
      ),
    );
  }
}
