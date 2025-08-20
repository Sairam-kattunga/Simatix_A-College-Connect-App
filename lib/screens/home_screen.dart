import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Import your screens
import 'faculty_directory.dart';
import 'course_pdfs.dart';
import 'cgpa_calculator.dart';
import 'attendance_calculator.dart';
import 'canteen_reviews.dart';
import 'department_subjects.dart';
import 'social_media_screen.dart';
import 'feedback_screen.dart';
import 'college_rules.dart';
import 'About_App.dart';
import 'CollegeInfoScreen.dart';
import 'Nearby_Places.dart';

// ----------------- Dashboard ------------------
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_HomeTileData> tiles = [
      _HomeTileData(
        icon: Icons.check_circle,
        title: 'ARMS Portal',
        subtitle: 'Access marks, timetable',
        iconColor: Colors.white,
        bgColor: Colors.indigo,
        onTap: () => _launchURL(
          context,
          'https://arms.sse.saveetha.com/Login.aspx?s=unauth',
        ),
      ),
      _HomeTileData(
        icon: Icons.fastfood,
        title: 'Food Portal',
        subtitle: 'Menu & mess details',
        iconColor: Colors.white,
        bgColor: Colors.orange,
        onTap: () => _launchURL(
          context,
          'https://life.saveetha.com/Login.aspx?type=s',
        ),
      ),
      _HomeTileData(
        icon: Icons.people,
        title: 'Faculty Directory',
        subtitle: 'Contact faculty',
        iconColor: Colors.white,
        bgColor: Colors.blue,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => const FacultyDirectoryScreen(),
              ));

          },
      ),
      _HomeTileData(
        icon: Icons.picture_as_pdf,
        title: 'Course PDFs',
        subtitle: 'View/download materials',
        iconColor: Colors.white,
        bgColor: Colors.red,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CoursePDFsScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.calculate,
        title: 'CGPA Calculator',
        subtitle: 'Calculate semester CGPA',
        iconColor: Colors.white,
        bgColor: Colors.teal,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CGPACalculatorScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.check_circle_outline,
        title: 'Attendance Calculator',
        subtitle: 'Calculate attendance %',
        iconColor: Colors.white,
        bgColor: Colors.green,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AttendanceCalculatorScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.restaurant_menu,
        title: 'Canteen Food Reviews',
        subtitle: 'View and share feedback',
        iconColor: Colors.white,
        bgColor: Colors.purple,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const FoodReviewScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.library_books,
        title: 'Department Subjects',
        subtitle: 'View subjects by branch',
        iconColor: Colors.white,
        bgColor: Colors.indigo,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DepartmentScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.rule,
        title: 'Simats Rules',
        subtitle: 'View regulations & policies',
        iconColor: Colors.white,
        bgColor: Colors.deepPurple,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CollegeRulesScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.group,
        title: 'Social Media',
        subtitle: 'Follow updates online',
        iconColor: Colors.white,
        bgColor: Colors.blueAccent,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SocialMediaScreen()));
        },
      ),

      // --- START: New Tiles ---
      _HomeTileData(
        icon: Icons.map_outlined, // Suitable icon for a map
        title: 'College Info',
        subtitle: 'Find your way around',
        iconColor: Colors.white,
        bgColor: Colors.brown, // Choose a distinct color
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CollegeInfoScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.attractions_outlined, // Suitable icon for attractions/places
        title: 'Nearby Places',
        subtitle: 'Explore local spots',
        iconColor: Colors.white,
        bgColor: Colors.cyan, // Choose a distinct color
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  NearbyPlacesScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.pending,
        title: 'About this app',
        subtitle: 'Stay tuned for updates',
        iconColor: Colors.white,
        bgColor: Colors.grey,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AboutAppScreen()));
        },
      ),
      _HomeTileData(
        icon: Icons.feedback,
        title: 'Feedback',
        subtitle: 'Submit suggestions',
        iconColor: Colors.white,
        bgColor: Colors.pink,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const FeedbackScreen()));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.indigo,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.dashboard, size: 26, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return _buildTile(
              context,
              icon: tile.icon,
              title: tile.title,
              subtitle: tile.subtitle,
              iconColor: tile.iconColor,
              bgColor: tile.bgColor,
              onTap: tile.onTap,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color iconColor,
        required Color bgColor,
        required VoidCallback onTap,
      }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      shadowColor: bgColor.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: bgColor.withOpacity(0.2),
        highlightColor: bgColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: bgColor,
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  _HomeTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
    required this.bgColor,
  });
}

// URL Launcher helper
Future<void> _launchURL(BuildContext context, String url) async {
  final Uri uri = Uri.parse(url);
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to open URL: $e")),
    );
  }
}
