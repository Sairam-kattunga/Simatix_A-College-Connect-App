// lib/screens/About_App.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/url_launcher_helper.dart'; // Ensure this path is correct

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  // --- Style Constants ---
  static const Color primaryBrandColor = Color(0xFF0D47A1); // Deep Blue
  static const Color accentBrandColor = Color(0xFF1976D2);  // Lighter Blue
  static const Color screenBackground = Color(0xFFF4F6F8); // Light grey background
  static const Color cardBackground = Colors.white;
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color iconColor = primaryBrandColor; // General icon color
  static const Color subtleDivider = Color(0xFFE0E0E0);

  static const String _updateUrl =
      'https://drive.google.com/file/d/1USY2W0PAjt32feYFrEJipRTPKLj1ySzW/view?usp=drive_link';

  // Method to open the update link
  // It takes BuildContext to pass to the UrlLauncherHelper for potential SnackBars
  void _openUpdateLink(BuildContext context) {
    UrlLauncherHelper.launchURL(_updateUrl);
  }

  // Helper widget to build individual feature tiles
  Widget _buildFeatureTile(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased padding
      child: Row(
        children: [
          CircleAvatar(
            radius: 22, // Slightly larger
            backgroundColor: primaryBrandColor.withOpacity(0.1),
            child: FaIcon(icon, color: primaryBrandColor, size: 20), // Adjusted size
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: primaryText.withOpacity(0.9)), // Adjusted style
            ),
          ),
        ],
      ),
    );
  }

  // Method to show the developer details dialog
  void _showDeveloperDetailsDialog(BuildContext screenContext) { // Renamed for clarity
    showDialog(
      context: screenContext, // Use the screen's context to show the dialog
      barrierDismissible: true,
      builder: (BuildContext dialogContext) { // This is the context for the dialog's content
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: cardBackground,
          elevation: 8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50, // Slightly larger
                  backgroundColor: primaryBrandColor,
                  child: FaIcon(FontAwesomeIcons.codeBranch, size: 45, color: Colors.white), // Changed icon
                  // backgroundImage: AssetImage('assets/developer_avatar.png'), // Optional
                ),
                const SizedBox(height: 16),
                const Text(
                  'K. R. V. M. SAIRAM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24, // Increased size
                    fontWeight: FontWeight.bold,
                    color: primaryBrandColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Flutter Developer',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: secondaryText.withOpacity(0.9)),
                ),
                const SizedBox(height: 16),
                Divider(color: subtleDivider.withOpacity(0.8), thickness: 1),
                const SizedBox(height: 16),
                // Pass dialogContext to _buildContactDetailRow for SnackBar functionality if URL fails
                _buildContactDetailRow(
                  dialogContext, // Use dialog's context here
                  icon: FontAwesomeIcons.solidEnvelope,
                  text: 'sairamkattunga333@gmail.com',
                  url: 'mailto:sairamkattunga333@gmail.com',
                  iconColor: Colors.red.shade700, // Specific color for email
                ),
                _buildContactDetailRow(
                  dialogContext, // Use dialog's context here
                  icon: FontAwesomeIcons.githubAlt, // Different GitHub icon
                  text: 'Sairam-kattunga',
                  url: 'https://github.com/Sairam-kattunga',
                  iconColor: Colors.black87,
                ),
                _buildContactDetailRow(
                  dialogContext, // Use dialog's context here
                  icon: FontAwesomeIcons.linkedinIn, // Specific LinkedIn icon
                  text: 'Connect on LinkedIn',
                  url: 'https://www.linkedin.com/in/sairamkrvm123/', // Replace with your actual URL
                  iconColor: const Color(0xFF0077B5), // LinkedIn Blue
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Close', style: TextStyle(color: primaryBrandColor, fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper for contact rows within the dialog
  Widget _buildContactDetailRow(
      BuildContext contextForUrlLauncher, // Context to be used by UrlLauncherHelper
          {
        required IconData icon,
        required String text,
        required String url,
        required Color iconColor, // Made iconColor required and specific per row
      }
      ) {
    return InkWell(
      onTap: () => UrlLauncherHelper.launchURL(url),
      borderRadius: BorderRadius.circular(12), // Smoother rounding
      splashColor: primaryBrandColor.withOpacity(0.1),
      highlightColor: primaryBrandColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Adjusted padding
        child: Row(
          children: [
            FaIcon(icon, color: iconColor, size: 22), // Use passed iconColor
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15.5, color: primaryText, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: secondaryText.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // This is the main screen's context
    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        title: const Text('About Simatix', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryBrandColor,
        foregroundColor: Colors.white,
        elevation: 3, // Slightly more pronounced shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 30), // Adjusted top padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppHeader(),
            const SizedBox(height: 28),
            _buildSectionCard(
              title: 'About Simatix',
              content: Text(
                'Simatix is a professional, modern, and intuitive app designed '
                    'to provide seamless access to faculty and institutional resources. '
                    'It helps students, staff, and faculty access rules, feedback, social media, '
                    'live updates, and other essential resources efficiently.',
                style: TextStyle(fontSize: 15.5, height: 1.65, color: secondaryText.withOpacity(0.95)),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Key Features',
              content: Column(
                children: [
                  _buildFeatureTile(context, FontAwesomeIcons.usersGear, 'Faculty directory with profiles'),
                  _buildFeatureTile(context, FontAwesomeIcons.bookOpenReader, 'College rules and guidelines'),
                  _buildFeatureTile(context, FontAwesomeIcons.solidCommentAlt, 'Feedback and reviews submission'),
                  _buildFeatureTile(context, FontAwesomeIcons.satelliteDish, 'Live updates & notifications'), // Changed icon
                  _buildFeatureTile(context, FontAwesomeIcons.fileLines, 'Course PDFs & academic calculators'), // Changed icon
                  _buildFeatureTile(context, FontAwesomeIcons.boltLightning, 'Fast, responsive, and user-friendly interface'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Pass the screen's context to the method that will show the dialog
            _buildDeveloperSectionTrigger(context),
            const SizedBox(height: 35),
            // Pass the screen's context to _openUpdateLink
            _buildUpdateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10), // Increased padding
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: primaryBrandColor.withOpacity(0.25), // Slightly stronger shadow
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: primaryBrandColor.withOpacity(0.4), width: 2.5),
          ),
          child: const CircleAvatar(
            radius: 60, // Larger logo
            backgroundImage: AssetImage('assets/logo.jpg'), // Ensure this asset exists
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Simatix',
          style: TextStyle(
            fontSize: 32, // Larger app name
            fontWeight: FontWeight.bold,
            color: primaryText,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Version 1.0.0', // Consider making this dynamic
          style: TextStyle(fontSize: 16, color: secondaryText.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      elevation: 4, // Increased elevation
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // More rounded
      color: cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(22), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 21, // Larger title
                fontWeight: FontWeight.w600, // Semi-bold
                color: primaryBrandColor,
              ),
            ),
            Divider(thickness: 1, height: 28, color: subtleDivider.withOpacity(0.9)), // Adjusted divider
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSectionTrigger(BuildContext screenContextForDialog) { // Context to show the dialog
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: cardBackground,
      child: InkWell(
        onTap: () => _showDeveloperDetailsDialog(screenContextForDialog),
        borderRadius: BorderRadius.circular(18),
        splashColor: primaryBrandColor.withOpacity(0.1),
        highlightColor: primaryBrandColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24), // Increased padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.userAstronaut, color: primaryBrandColor, size: 24), // Changed icon
                  const SizedBox(width: 18),
                  const Text(
                    'About the Developer',
                    style: TextStyle(
                        fontSize: 18, // Larger text
                        fontWeight: FontWeight.w600,
                        color: primaryText),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: secondaryText.withOpacity(0.8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext contextForUrlLaunch) { // Context for the URL launcher
    return SizedBox(
      height: 55, // Taller button
      child: ElevatedButton.icon(
        onPressed: () => _openUpdateLink(contextForUrlLaunch),
        icon: const FaIcon(FontAwesomeIcons.cloudArrowDown, size: 22, color: Colors.white),
        label: const Text(
          'Check for Updates',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBrandColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // More rounded
          ),
          elevation: 4,
          shadowColor: accentBrandColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
