// lib/screens/maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class MaintenanceScreen extends StatelessWidget {
  final String message;
  final String? until;
  final String? contactEmail; // Use descriptive name
  final bool forceUpdate;

  const MaintenanceScreen({
    super.key,
    this.message = "We're currently making some improvements behind the scenes.",
    this.until,
    this.contactEmail,
    this.forceUpdate = false,
  });

  // --- Theme constants ---
  static const Color primaryWarningColor = Color(0xFFFFC107);
  static const Color accentWarningColor = Color(0xFFFFA000);
  static const Color darkBackgroundColor = Color(0xFF212121);
  static const Color darkCardColor = Color(0xFF303030);
  static const Color lightTextColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;
  static const Color detailHighlightColor = Color(0xFF81D4FA);
  static const Color emailActionColor = Color(0xFF90CAF9);

  String _formatUntil(String? untilRaw) {
    if (untilRaw == null || untilRaw.isEmpty) return '';
    try {
      final dt = DateTime.parse(untilRaw);
      return 'Approx. ${dt.toLocal().toString().split(".")[0].replaceAll("-", "/")}';
    } catch (_) {
      return untilRaw;
    }
  }

  // --- Email Launcher ---
  Future<void> _launchEmail(BuildContext context, String emailAddress) async {
    if (!emailAddress.contains('@')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid contact email address: $emailAddress'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'Inquiry from App User (Maintenance)'},
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch ${emailLaunchUri.toString()}';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email app: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final untilText = _formatUntil(until);
    final displayMessage = message.replaceAll('"', '');

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: darkCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryWarningColor.withOpacity(0.7), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: primaryWarningColor.withOpacity(0.25),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMaintenanceIcon(),
                const SizedBox(height: 25),
                Text(
                  "Under Construction!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primaryWarningColor,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  displayMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                ),
                if (untilText.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildInfoChip(
                    icon: FontAwesomeIcons.clock,
                    label: 'Expected Back By:',
                    value: untilText,
                    iconColor: detailHighlightColor,
                  ),
                ],
                if (contactEmail != null && contactEmail!.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  _buildContactChip(context),
                ],
                const SizedBox(height: 25),
                Divider(color: primaryWarningColor.withOpacity(0.4), thickness: 1),
                const SizedBox(height: 20),
                const Text(
                  "We're tightening some bolts and polishing the pixels!\nThanks for your patience. 🛠️✨",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryWarningColor,
                    foregroundColor: darkBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: accentWarningColor, width: 2),
                    ),
                    elevation: 5,
                    shadowColor: accentWarningColor.withOpacity(0.5),
                  ),
                  icon: const Icon(FontAwesomeIcons.doorClosed, size: 20),
                  label: const Text(
                    "Alright, I'll Wait!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryWarningColor.withOpacity(0.15),
        border: Border.all(color: primaryWarningColor.withOpacity(0.5), width: 2),
      ),
      child: const FaIcon(
        FontAwesomeIcons.helmetSafety,
        size: 70,
        color: primaryWarningColor,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: darkBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: secondaryTextColor),
                children: [
                  TextSpan(
                    text: '$label\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: iconColor.withOpacity(0.9),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: lightTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip(BuildContext context) {
    final cleanEmail = contactEmail!.replaceAll('"', '');
    return InkWell(
      onTap: () => _launchEmail(context, cleanEmail),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: darkBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: detailHighlightColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.solidEnvelope, size: 18, color: detailHighlightColor),
            const SizedBox(width: 10),
            Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, color: secondaryTextColor),
                  children: [
                    TextSpan(
                      text: 'Need Help? Contact:\n',
                      style: TextStyle(fontWeight: FontWeight.w600, color: detailHighlightColor.withOpacity(0.9)),
                    ),
                    TextSpan(
                      text: cleanEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: emailActionColor,
                        decoration: TextDecoration.underline,
                        decorationColor: emailActionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.open_in_new, size: 16, color: emailActionColor),
          ],
        ),
      ),
    );
  }
}
