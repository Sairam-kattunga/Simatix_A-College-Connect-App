import 'package:flutter/material.dart';

class CGPACalculatorScreen extends StatefulWidget {
  const CGPACalculatorScreen({super.key});

  @override
  State<CGPACalculatorScreen> createState() => _CGPACalculatorScreenState();
}

class _CGPACalculatorScreenState extends State<CGPACalculatorScreen> {
  final TextEditingController sGradeController = TextEditingController();
  final TextEditingController aGradeController = TextEditingController();
  final TextEditingController bGradeController = TextEditingController();
  final TextEditingController cGradeController = TextEditingController();
  final TextEditingController dGradeController = TextEditingController();
  final TextEditingController eGradeController = TextEditingController();

  double cgpa = 0.0;
  String cgpaComment = '';

  // --- New Color Palette ---
  static const Color primaryColor = Color(0xFF00796B); // Teal - Professional & Calming
  static const Color accentColor = Color(0xFF00ACC1);  // Lighter Cyan/Teal - Accent
  static const Color screenBackgroundColor = Color(0xFFF5F7FA); // Very Light Grey/Blue
  static const Color cardBackgroundColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF333333); // Dark Grey for text
  static const Color secondaryTextColor = Color(0xFF555555); // Slightly lighter grey
  static const Color inputBorderColor = Color(0xFFD0D0D0);
  static const Color successColor = Color(0xFF4CAF50); // Green for positive comments
  static const Color warningColor = Color(0xFFFFA000); // Amber for cautionary comments
  static const Color errorColor = Color(0xFFD32F2F);   // Red for critical comments

  void calculateCGPA() {
    // Ensure the widget is still mounted before showing dialog or setting state
    if (!mounted) return;

    int s = int.tryParse(sGradeController.text) ?? 0;
    int a = int.tryParse(aGradeController.text) ?? 0;
    int b = int.tryParse(bGradeController.text) ?? 0;
    int c = int.tryParse(cGradeController.text) ?? 0;
    int d = int.tryParse(dGradeController.text) ?? 0;
    int e = int.tryParse(eGradeController.text) ?? 0;

    final totalPoints = (s * 10) + (a * 9) + (b * 8) + (c * 7) + (d * 6) + (e * 5);
    final totalSubjects = s + a + b + c + d + e;

    setState(() {
      cgpa = totalSubjects > 0 ? totalPoints / totalSubjects : 0.0;
      cgpaComment = _getComment(cgpa);
    });

    // Show overlay result
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (_) => _buildResultDialog(),
    );
  }

  String _getComment(double localCgpa) { // Use localCgpa to avoid relying on state during calculation
    if (localCgpa >= 9) return "Outstanding! Keep shining like a star!";
    if (localCgpa >= 8) return "Excellent! You’re doing great!";
    if (localCgpa >= 7) return "Good Work! Aim higher next time.";
    if (localCgpa >= 6) return "Satisfactory. Time to focus a bit more.";
    if (localCgpa >= 5) return "Needs Improvement. Let’s work on strategies!";
    return "Critical. Seek guidance and plan your studies.";
  }

  Color _getCommentColor(double localCgpa) {
    if (localCgpa >= 9) return successColor;
    if (localCgpa >= 8) return successColor.withOpacity(0.8);
    if (localCgpa >= 7) return primaryColor;
    if (localCgpa >= 6) return warningColor;
    if (localCgpa >= 5) return errorColor.withOpacity(0.8);
    return errorColor;
  }

  IconData _getCommentIcon(double localCgpa) {
    if (localCgpa >= 9) return Icons.star_rounded;
    if (localCgpa >= 8) return Icons.thumb_up_alt_rounded;
    if (localCgpa >= 7) return Icons.check_circle_outline_rounded;
    if (localCgpa >= 6) return Icons.hourglass_top_rounded;
    if (localCgpa >= 5) return Icons.warning_amber_rounded;
    return Icons.error_outline_rounded;
  }


  Widget _buildResultDialog() {
    Color commentColor = _getCommentColor(cgpa);
    IconData commentIcon = _getCommentIcon(cgpa);

    return Dialog(
      backgroundColor: Colors.transparent, // Make dialog background transparent for custom shape
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: commentColor.withOpacity(0.15),
              child: Icon(commentIcon, size: 40, color: commentColor),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your CGPA is:',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: secondaryTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              cgpa.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: commentColor, // Use the comment color for CGPA too
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                cgpaComment,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w500, color: commentColor.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if(mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 3,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputFields = [
      _buildGradeInputField('S Grade (10 points)', sGradeController, icon: Icons.school_rounded), // Unique icon
      _buildGradeInputField('A Grade (9 points)', aGradeController, icon: Icons.star_outline_rounded),
      _buildGradeInputField('B Grade (8 points)', bGradeController, icon: Icons.emoji_events_outlined),
      _buildGradeInputField('C Grade (7 points)', cGradeController, icon: Icons.check_circle_outline),
      _buildGradeInputField('D Grade (6 points)', dGradeController, icon: Icons.bookmark_border_rounded),
      _buildGradeInputField('E Grade (5 points)', eGradeController, icon: Icons.edit_note_rounded),
    ];

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('CGPA Calculator', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // For back button and other icons
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)), // Slightly more rounded
              elevation: 5, // Softer shadow
              shadowColor: Colors.black.withOpacity(0.1),
              color: cardBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(24), // Increased padding
                child: Column(
                  children: [
                    const Text(
                      'Enter the number of subjects for each grade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColor, // Use primary color for heading
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    ...inputFields,
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: calculateCGPA,
                      icon: const Icon(Icons.calculate_rounded, size: 22),
                      label: const Text(
                        'Calculate CGPA',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // Use accent color for main action
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55), // Slightly taller button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 4,
                        shadowColor: accentColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildGradeInputField(String label, TextEditingController controller, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Increased vertical padding
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: primaryTextColor, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: secondaryTextColor),
          filled: true,
          fillColor: screenBackgroundColor.withOpacity(0.7), // Slightly transparent fill
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.8), size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: inputBorderColor.withOpacity(0.7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: inputBorderColor.withOpacity(0.7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Adjust padding
        ),
      ),
    );
  }
}
