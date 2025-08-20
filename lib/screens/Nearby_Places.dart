import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ------------------ MODEL ------------------
class Place {
  final String name;
  final String category;
  final String description;
  final String mapUrl;
  final String suggestedBy;
  final String distanceKm;

  Place({
    required this.name,
    required this.category,
    required this.description,
    required this.mapUrl,
    required this.suggestedBy,
    required this.distanceKm,
  });

  static String _read(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      if (json.containsKey(k)) return (json[k] ?? '').toString().trim();
    }
    final trimmed = <String, dynamic>{};
    json.forEach((k, v) => trimmed[k.trim()] = v);
    for (final k in keys) {
      final kk = k.trim();
      if (trimmed.containsKey(kk)) return (trimmed[kk] ?? '').toString().trim();
    }
    return '';
  }

  factory Place.fromJson(Map<String, dynamic> raw) {
    return Place(
      name: _read(raw, ['Place Name']),
      category: _read(raw, ['Category(Ex. Beach, Restaurant)', 'Category']),
      description: _read(raw, ['Description(About the place or food)', 'Description']),
      mapUrl: _read(raw, ['Google Map URL', ' Google Map URL ']),
      suggestedBy: _read(raw, ['Suggested By (Enter your name)', ' Suggested By (Enter your name)', 'Suggested By   (Enter your name)']),
      distanceKm: _read(raw, ['Distance(From College)', ' Distance(From College) ']),
    );
  }
}

/// Category-based icons (Using FontAwesome for more variety)
IconData getCategoryIcon(String category) {
  switch (category.toLowerCase().trim()) {
    case "beach":
      return FontAwesomeIcons.umbrellaBeach;
    case "restaurant":
      return FontAwesomeIcons.utensils;
    case "temple":
      return FontAwesomeIcons.gopuram; // Hindu temple icon
    case "church":
      return FontAwesomeIcons.church;
    case "mosque":
      return FontAwesomeIcons.mosque;
    case "park":
      return FontAwesomeIcons.tree; // More generic park icon
    case "museum":
      return FontAwesomeIcons.landmark; // Could also be buildingColumns
    case "shopping":
    case "mall":
      return FontAwesomeIcons.bagShopping;
    case "cafe":
      return FontAwesomeIcons.mugSaucer; // Or coffee
    case "hotel":
      return FontAwesomeIcons.hotel;
    case "mountain":
      return FontAwesomeIcons.mountainSun; // Scenic mountain
    case "lake":
    case "waterfall":
      return FontAwesomeIcons.water;
    case "trekking":
    case "hiking":
      return FontAwesomeIcons.personHiking;
    case "resort":
      return FontAwesomeIcons.umbrellaBeach; // Often associated with resorts
    case "viewpoint":
      return FontAwesomeIcons.binoculars;
    case "historical site":
      return FontAwesomeIcons.landmarkFlag;
    default:
      List<IconData> holidayIcons = [
        FontAwesomeIcons.sun,
        FontAwesomeIcons.planeDeparture,
        FontAwesomeIcons.cocktail,
        FontAwesomeIcons.cameraRetro,
        FontAwesomeIcons.mapMarkedAlt,
        FontAwesomeIcons.compass,
        FontAwesomeIcons.tree, // Vacation vibe
      ];
      holidayIcons.shuffle();
      return holidayIcons.first;
  }
}

// Icon for distance
IconData getDistanceIcon() {
  return FontAwesomeIcons.road; // Or mapMarkerAlt, route
}

// Icon for suggested by
IconData getSuggestedByIcon() {
  return FontAwesomeIcons.userCheck; // Or userEdit, userTag
}


/// ------------------ SCREEN ------------------
class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  static const String _apiUrl =
      "https://script.google.com/macros/s/AKfycbz-JXSfU0S3jh-ucZCY4fELk_hWv2R3dQXkKtqjmajz60EQXYeCTsoTuJL-1qu7tng3Zg/exec";
  static const String _formUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSdomJtdQ9IQvqwBl4_zvfafD0xeRBWl_F5jn6_Qiv5dbpMTtg/viewform?usp=sf_link"; // Ensured form URL is a direct link

  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  List<Place> _all = [];
  List<Place> _filtered = [];

  // Define vacation-themed colors
  static const Color primaryVacationColor = Color(0xFF00A79D); // Tealish blue
  static const Color accentVacationColor = Color(0xFFFFC107); // Sunny yellow
  static const Color backgroundVacationColor = Color(0xFFFFF8E1); // Light cream
  static const Color cardVacationColor = Colors.white; // Keep cards clean
  static const Color textVacationColor = Color(0xFF333333); // Dark grey for readability
  static const Color subtleTextColor = Colors.black54;


  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  bool _looksLikeHtml(String body) {
    final start = body.trimLeft();
    return start.startsWith('<!doctype') ||
        start.startsWith('<html') ||
        start.contains('<head>') ||
        start.contains('</html>');
  }

  Future<void> _fetchPlaces() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await http.get(Uri.parse(_apiUrl));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final body = resp.body;
      if (_looksLikeHtml(body)) {
        throw Exception(
          'The endpoint returned HTML, not JSON. Make sure your Apps Script is deployed as a Web App '
              '(Execute as: Me, Access: Anyone).',
        );
      }

      final decoded = json.decode(body);
      final List<dynamic> rows =
      decoded is List ? decoded : (decoded['data'] as List<dynamic>);

      final places = rows
          .whereType<Map<String, dynamic>>()
          .map((m) => Place.fromJson(m))
          .where((p) => p.name.isNotEmpty)
          .toList();

      setState(() {
        _all = places;
        _filtered = places;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load places: $e. Please check your internet connection and the data source.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_error!), duration: const Duration(seconds: 5), backgroundColor: Colors.red.shade700),
          );
        }
      });
    }
  }

  void _filter(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query); // Also search in description
        }).toList();
      }
    });
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No URL provided to open.'), backgroundColor: Colors.orangeAccent),
        );
      }
      return;
    }
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  void _showDetails(BuildContext context, Place p) { // Pass context
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: backgroundVacationColor, // Dialog background
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryVacationColor.withOpacity(0.2),
                child: FaIcon(
                  getCategoryIcon(p.category),
                  size: 45,
                  color: primaryVacationColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                p.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textVacationColor),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(getCategoryIcon(p.category), size: 16, color: primaryVacationColor),
                  const SizedBox(width: 8),
                  Text(
                    p.category.isNotEmpty ? p.category : "Place",
                    style: const TextStyle(fontSize: 16, color: subtleTextColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (p.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    p.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: textVacationColor, height: 1.4),
                  ),
                ),
              const SizedBox(height: 20),
              Divider(color: primaryVacationColor.withOpacity(0.3)),
              const SizedBox(height: 16),
              if (p.distanceKm.isNotEmpty)
                _buildDetailRow(
                  icon: getDistanceIcon(),
                  label: 'Distance:',
                  value: '${p.distanceKm} km',
                ),
              if (p.suggestedBy.isNotEmpty)
                _buildDetailRow(
                  icon: getSuggestedByIcon(),
                  label: 'Suggested by:',
                  value: p.suggestedBy,
                ),
              const SizedBox(height: 24),
              if (p.mapUrl.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _openUrl(p.mapUrl),
                  icon: const FaIcon(FontAwesomeIcons.mapLocationDot, size: 18),
                  label: const Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentVacationColor,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: primaryVacationColor, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for detail rows in the dialog
  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FaIcon(icon, size: 18, color: primaryVacationColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15, color: textVacationColor, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: subtleTextColor))),
        ],
      ),
    );
  }


  String _initials(String name) { // Kept for potential fallback if needed, but not used in current tile
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12), // Adjusted margin
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardVacationColor,
        borderRadius: BorderRadius.circular(30), // More rounded
        boxShadow: [
          BoxShadow(
            color: primaryVacationColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _filter,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: primaryVacationColor.withOpacity(0.7)),
          hintText: 'Search destinations (e.g., beach, cafe)...',
          hintStyle: TextStyle(color: subtleTextColor.withOpacity(0.8)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Modified tile widget
  Widget _tile(Place p, BuildContext context) { // Pass context
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      color: cardVacationColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // More rounded
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell(
        onTap: () => _showDetails(context, p), // Use passed context
        splashColor: primaryVacationColor.withOpacity(0.1),
        highlightColor: primaryVacationColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                maxLines: 2, // Allow for slightly longer names
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: textVacationColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FaIcon(getCategoryIcon(p.category), size: 16, color: primaryVacationColor),
                  const SizedBox(width: 8),
                  Expanded( // Use Expanded to prevent overflow if category name is long
                    child: Text(
                      p.category.isNotEmpty ? p.category : "Place",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: subtleTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (p.distanceKm.isNotEmpty)
                Row(
                  children: [
                    FaIcon(getDistanceIcon(), size: 16, color: primaryVacationColor),
                    const SizedBox(width: 8),
                    Text(
                      '${p.distanceKm} km',
                      style: const TextStyle(fontSize: 14, color: subtleTextColor),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundVacationColor, // Overall screen background
      appBar: AppBar(
        title: const Text(
          "Explore Nearby Cool Spots", // More thematic title
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryVacationColor, // AppBar color
        foregroundColor: Colors.white, // Color for icons and back button
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plusCircle), // Changed to FontAwesome icon
            tooltip: 'Suggest a New Place',
            onPressed: () => _openUrl(_formUrl),
          ),
          const SizedBox(width: 8), // Some spacing
        ],
      ),
      body: Column(
        children: [
          _searchBar(),
          if (_loading)
            const Expanded(
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentVacationColor)),
                        SizedBox(height: 16),
                        Text("Finding amazing spots...", style: TextStyle(color: textVacationColor, fontSize: 16))
                      ],
                    )
                )
            )
          else if (_error != null && _filtered.isEmpty) // Show error more prominently if filtering leads to no results after error
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.cloudSunRain, size: 60, color: Colors.orangeAccent),
                      const SizedBox(height: 20),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, color: textVacationColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                        onPressed: _fetchPlaces,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accentVacationColor,
                            foregroundColor: textVacationColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          else if (_filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.mapSigns, size: 60, color: Colors.grey), // Changed icon
                      SizedBox(height: 20),
                      Text(
                        "No matching getaways found.\nTry a different search!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: textVacationColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16, top: 4), // Add padding
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final place = _filtered[index];
                    return _tile(place, context); // Pass context to _tile
                  },
                ),
              ),
        ],
      ),
      // Removed FloatingActionButton as it's now in AppBar
    );
  }
}
