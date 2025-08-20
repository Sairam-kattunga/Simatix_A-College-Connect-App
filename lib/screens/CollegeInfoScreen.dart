import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For more icon options

class CollegeInfoScreen extends StatelessWidget {
  const CollegeInfoScreen({super.key});

  // --- Style Constants ---
  static const Color primaryColor = Color(0xFF0D47A1); // Deep Blue (Professional)
  static const Color accentColor = Color(0xFF1976D2);  // Brighter Blue
  static const Color lightScaffoldBackground = Color(0xFFF4F6F8); // Very light grey
  static const Color cardBackgroundColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF212121); // Dark grey for text
  static const Color secondaryTextColor = Color(0xFF757575); // Lighter grey for subtitles
  static const Color iconColor = primaryColor;

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightScaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0, // Increased height for image and title
            floating: false,
            pinned: true,
            snap: false,
            elevation: 4,
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white), // Back button color
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Center title when collapsed
              titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              title: const Text(
                'SIMATS University', // Using a more common abbreviation if applicable
                style: TextStyle(
                    fontSize: 18.0, // Smaller when collapsed
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 2, color: Colors.black38, offset: Offset(1,1))
                    ]
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/college.png', // Ensure this image is high quality
                    fit: BoxFit.cover,
                  ),
                  Container( // Gradient overlay for better text readability on image
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned( // College name prominently on the image (when expanded)
                    bottom: 70, // Adjust positioning
                    left: 20,
                    right: 20,
                    child: Text(
                      'Saveetha Institute of Medical And Technical Sciences',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26, // Larger when expanded
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 3, color: Colors.black.withOpacity(0.7), offset: Offset(1,2))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoSection(context),
                  const SizedBox(height: 30),
                  _buildActionButtons(context),
                  const SizedBox(height: 30),
                  _buildFooterNote(context),
                  const SizedBox(height: 20), // Extra padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero, // Use padding from parent
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 10),
            const InfoRow(icon: FontAwesomeIcons.buildingColumns, title: 'Type', value: 'Private Deemed University'),
            const InfoRow(icon: FontAwesomeIcons.calendarDay, title: 'Established', value: '2005'),
            const InfoRow(icon: FontAwesomeIcons.certificate, title: 'Accreditation', value: 'NAAC'),
            const InfoRow(icon: FontAwesomeIcons.link, title: 'Affiliation', value: 'NMC'),
            const InfoRow(icon: FontAwesomeIcons.userTie, title: 'Chairman', value: 'Dr. N. V. Veerian'),
            const InfoRow(icon: FontAwesomeIcons.userGraduate, title: 'Vice-Chancellor', value: 'Dr. Rakesh Kumar Sharma'),
            const InfoRow(icon: FontAwesomeIcons.mapPin, title: 'Location', value: 'Thandalam, Chennai, Tamil Nadu, India'),
            const InfoRow(icon: FontAwesomeIcons.city, title: 'Campus', value: 'Urban'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              const mapUrl = 'https://maps.app.goo.gl/BskSxQcsMWnNvXzC6';
              _launchUrl(mapUrl, context);
            },
            icon: const FaIcon(FontAwesomeIcons.mapLocationDot, color: Colors.white, size: 20),
            label: const Text('Open Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: accentColor.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              const websiteUrl = 'https://www.saveetha.com';
              _launchUrl(websiteUrl, context);
            },
            icon: const FaIcon(FontAwesomeIcons.globe, color: Colors.white, size: 20),
            label: const Text('Website'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor, // Consistent button style or use primaryColor
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: accentColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05), // Very light background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(FontAwesomeIcons.circleInfo, color: primaryColor.withOpacity(0.8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For detailed department information, course offerings, or insights into campus life, please visit the official college website or explore the campus map.',
              style: TextStyle(color: secondaryTextColor, fontSize: 14, height: 1.5),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 18, color: CollegeInfoScreen.iconColor.withOpacity(0.85)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CollegeInfoScreen.primaryTextColor.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                      color: CollegeInfoScreen.secondaryTextColor,
                      fontSize: 15,
                      height: 1.4
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
