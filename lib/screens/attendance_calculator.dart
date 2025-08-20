import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For icons

class AttendanceCalculatorScreen extends StatefulWidget {
  const AttendanceCalculatorScreen({super.key});

  @override
  State<AttendanceCalculatorScreen> createState() =>
      _AttendanceCalculatorScreenState();
}

class _AttendanceCalculatorScreenState
    extends State<AttendanceCalculatorScreen> {
  final TextEditingController _totalClassesController = TextEditingController();
  final TextEditingController _attendedClassesController =
  TextEditingController();
  final TextEditingController _requiredPercentageController =
  TextEditingController(text: '80'); // Default to 80%

  String _resultMessage = '';
  Color _resultColor = Colors.transparent;
  IconData _resultIcon = Icons.info_outline_rounded;

  // --- Color Palette (Consistent with CGPA Calculator) ---
  static const Color primaryColor = Color(0xFF00796B); // Teal
  static const Color accentColor = Color(0xFF00ACC1);  // Lighter Cyan/Teal
  static const Color screenBackgroundColor = Color(0xFFF5F7FA);
  static const Color cardBackgroundColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF555555);
  static const Color inputBorderColor = Color(0xFFD0D0D0);
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFA000); // Amber
  static const Color errorColor = Color(0xFFD32F2F);   // Red

  @override
  void dispose() {
    _totalClassesController.dispose();
    _attendedClassesController.dispose();
    _requiredPercentageController.dispose();
    super.dispose();
  }

  void _calculateAttendance() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    final int totalClasses = int.tryParse(_totalClassesController.text) ?? 0;
    final int attendedClasses =
        int.tryParse(_attendedClassesController.text) ?? 0;
    final double requiredPercentage =
        double.tryParse(_requiredPercentageController.text) ?? 75.0;

    if (!mounted) return;

    if (totalClasses <= 0 && requiredPercentage > 0) { // If no classes held yet, but attendance is required
      if (requiredPercentage == 100) {
        setState(() {
          _resultMessage = 'You need to attend every future class to maintain 100%.';
          _resultColor = warningColor;
          _resultIcon = FontAwesomeIcons.personChalkboard;
        });
      } else {
        double R = requiredPercentage / 100.0;
        // X / (0+X) = R => X = RX => X(1-R) = 0. This formula needs care for totalClasses = 0
        // If total classes = 0, we need to attend X future classes such that X/X = 100% >= R
        // Or more generally, Y attended / Y total >= R.
        // How many classes 'X' to attend such that X/X >= R.
        // This really means we need to consider the *next* set of classes.
        // Let's say we need to attend 'c' consecutive future classes.
        // c / c >= R. This is true if c >=1 for R <=100.
        // The phrasing should be "You need to attend the next X classes..."
        int consecutiveNeeded;
        if (R > 0 && R < 1.0) { // Avoid division by zero if R is 1.0 or 0
          consecutiveNeeded = (R / (1.0 - R)).ceil(); // This formula doesn't quite fit here
          // Simplified: If you start from 0, to reach R%, you need to attend at least 1 class if R > 0.
          // The logic for "additionalConsecutiveClasses" below handles this better.
          // For now, give a generic message or use the detailed calculation.
          setState(() {
            _resultMessage = "Start by attending classes. Your future attendance will determine if you meet ${requiredPercentage.toStringAsFixed(0)}%.";
            _resultColor = warningColor;
            _resultIcon = FontAwesomeIcons.infoCircle;
          });

        } else if (R == 1.0) {
          setState(() {
            _resultMessage = "You must attend all future classes to achieve 100%.";
            _resultColor = errorColor;
            _resultIcon = FontAwesomeIcons.triangleExclamation;
          });
        } else { // R = 0 or invalid
          setState(() {
            _resultMessage = 'Please enter a valid required percentage.';
            _resultColor = errorColor;
            _resultIcon = Icons.error_outline_rounded;
          });
        }
      }
      return;
    }


    if (requiredPercentage <= 0 || requiredPercentage > 100) {
      setState(() {
        _resultMessage = 'Please enter a valid required percentage (1-100).';
        _resultColor = errorColor;
        _resultIcon = Icons.error_outline_rounded;
      });
      return;
    }

    if (attendedClasses > totalClasses && totalClasses > 0) { // also ensure totalClasses > 0 here
      setState(() {
        _resultMessage =
        'Attended classes cannot be more than total classes.';
        _resultColor = errorColor;
        _resultIcon = FontAwesomeIcons.circleExclamation;
      });
      return;
    }

    double currentPercentage = (totalClasses > 0) ? (attendedClasses / totalClasses) * 100 : 0.0;
    int maxBunks;
    double R = requiredPercentage / 100.0;

    if (currentPercentage >= requiredPercentage) {
      maxBunks = (R > 0) ? ((attendedClasses - (R * totalClasses)) / R).floor() : totalClasses; // Avoid division by zero if R=0
      maxBunks = maxBunks < 0 ? 0 : maxBunks;
      setState(() {
        _resultMessage =
        "You're safe! Current: ${currentPercentage.toStringAsFixed(2)}%.\nYou can bunk a maximum of $maxBunks more class${maxBunks == 1 ? '' : 'es'} and maintain ${requiredPercentage.toStringAsFixed(0)}% attendance.";
        _resultColor = successColor;
        _resultIcon = FontAwesomeIcons.solidCircleCheck;
      });
    } else {
      // User is below the required percentage
      int classesToAttendBasedOnFormula = 0;
      if (1 - R > 0.00001) { // Avoid division by zero or near-zero for R close to 1
        double rawClassesToAttend = (R * totalClasses - attendedClasses) / (1 - R);
        classesToAttendBasedOnFormula = rawClassesToAttend < 0 ? 0 : rawClassesToAttend.ceil();
      } else if (R >= 1.0) { // Required 100% or more (though >100% is validated out)
        // If 100% is required and they are below, they effectively need to attend all future classes perfectly.
        // This scenario is better handled by "additionalConsecutiveClasses" or a specific message.
        classesToAttendBasedOnFormula = (totalClasses - attendedClasses) > 0 ? (totalClasses - attendedClasses) + (totalClasses) : 1000; // Heuristic: many
      }


      if (R == 1.0 && attendedClasses < totalClasses) {
        setState(() {
          _resultMessage =
          "Current: ${currentPercentage.toStringAsFixed(2)}%.\nWith 100% required, and past classes missed, you must attend all remaining future classes perfectly.";
          _resultColor = errorColor;
          _resultIcon = FontAwesomeIcons.triangleExclamation;
        });
        return;
      }

      int additionalConsecutiveClasses = 0;
      double tempAttended = attendedClasses.toDouble();
      double tempTotal = totalClasses.toDouble();

      // This loop calculates how many *new, consecutive* classes must be attended
      // Only run if actually below and it's possible to improve (R < 1 or tempAttended < tempTotal if R=1)
      if (currentPercentage < requiredPercentage && (R < 1.0 || (R == 1.0 && tempAttended == tempTotal))) {
        // If starting from 0 total classes, and R > 0.
        if (totalClasses == 0 && R > 0) {
          tempAttended = 0; // Reset for calculation from scratch
          tempTotal = 0;
          // Loop until the condition is met by adding new classes that are all attended
          while(true) {
            additionalConsecutiveClasses++;
            tempAttended = additionalConsecutiveClasses.toDouble();
            tempTotal = additionalConsecutiveClasses.toDouble();
            if (tempTotal == 0) continue; // Should not happen if additionalConsecutiveClasses > 0
            if ((tempAttended / tempTotal * 100.0) >= requiredPercentage) break;
            if (additionalConsecutiveClasses > 1000) { // Safety break
              additionalConsecutiveClasses = 1001; // Indicate impossibility
              break;
            }
          }
        } else if (1.0 - R > 0.00001) { // Normal case where R < 1.0
          while ((tempAttended / tempTotal * 100.0) < requiredPercentage) {
            tempAttended++;
            tempTotal++;
            additionalConsecutiveClasses++;
            if (additionalConsecutiveClasses > (totalClasses * 3) + 20 && totalClasses > 0) { // Increased safety break
              additionalConsecutiveClasses = (totalClasses * 3) + 21; // Indicate near impossibility
              break;
            }
            if (additionalConsecutiveClasses > 1000 && totalClasses == 0) break; // Break for initially 0 classes
          }
        } else { // R is 1.0 or extremely close, and they are not yet at 100%
          // This case should ideally be caught by "R == 1.0 && attendedClasses < totalClasses"
          // If they are here, it means current is < 100% but R is 1.0.
          // Implies they need to attend all future hypothetical classes perfectly.
          // The number is theoretically infinite if we don't cap total classes.
          // For display, it's better to say "all future classes".
          // The specific message for 100% is clearer.
        }
      }


      if (additionalConsecutiveClasses > (totalClasses * 2) + 10 && totalClasses > 0 && additionalConsecutiveClasses < 1000) { // Heuristic for "very difficult"
        setState(() {
          _resultMessage =
          "Current: ${currentPercentage.toStringAsFixed(2)}%.\nIt will require attending approximately $additionalConsecutiveClasses more classes consecutively, which seems very difficult with current totals. Please verify inputs.";
          _resultColor = errorColor;
          _resultIcon = FontAwesomeIcons.triangleExclamation;
        });
      } else if (additionalConsecutiveClasses >= 1000) { // Impossible or took too long
        setState(() {
          _resultMessage =
          "Current: ${currentPercentage.toStringAsFixed(2)}%.\nIt appears impossible to reach ${requiredPercentage.toStringAsFixed(0)}% with the provided numbers or it requires an extremely large number of consecutive classes.";
          _resultColor = errorColor;
          _resultIcon = FontAwesomeIcons.ban;
        });
      }
      else if (additionalConsecutiveClasses > 0) {
        setState(() {
          _resultMessage =
          "Current: ${currentPercentage.toStringAsFixed(2)}%.\nYou need to attend the next $additionalConsecutiveClasses class${additionalConsecutiveClasses == 1 ? '' : 'es'} consecutively to reach ${requiredPercentage.toStringAsFixed(0)}%.";
          _resultColor = warningColor;
          _resultIcon = FontAwesomeIcons.personChalkboard;
        });
      } else if (currentPercentage < requiredPercentage && classesToAttendBasedOnFormula > 0) {
        // Fallback to the formula if consecutive calculation resulted in 0 but they are still under
        setState(() {
          _resultMessage =
          "Current: ${currentPercentage.toStringAsFixed(2)}%.\nYou need to attend $classesToAttendBasedOnFormula more class${classesToAttendBasedOnFormula == 1 ? '' : 'es'} (assuming these are new classes being added) to reach ${requiredPercentage.toStringAsFixed(0)}%.";
          _resultColor = warningColor;
          _resultIcon = FontAwesomeIcons.personChalkboard;
        });
      }
      else {
        // Should ideally be caught by currentPercentage >= requiredPercentage, or other conditions.
        // This is a fallback if other logic paths were missed.
        setState(() {
          _resultMessage = "Please check your inputs. Unable to determine specific action. Current: ${currentPercentage.toStringAsFixed(2)}%";
          _resultColor = errorColor;
          _resultIcon = Icons.error_outline_rounded;
        });
      }
    }
  }

  // --- BUILD METHOD AND WIDGETS (AppBar, _buildInputCard, _buildTextField, _buildResultDisplay) ---
  // --- These remain the same as the previously provided correctly styled versions ---
  // --- Make sure to copy them from the previous correct response for the UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Attendance Calculator',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _calculateAttendance,
              icon: const Icon(Icons.calculate_rounded, size: 22),
              label: const Text('Calculate',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 4,
                shadowColor: accentColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 25),
            if (_resultMessage.isNotEmpty) _buildResultDisplay(),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.1),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Attendance Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _totalClassesController,
              label: 'Total Classes Held',
              icon: FontAwesomeIcons.calendarDays,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _attendedClassesController,
              label: 'Classes You Attended',
              icon: FontAwesomeIcons.userCheck,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _requiredPercentageController,
              label: 'Required Attendance % (e.g., 80)',
              icon: FontAwesomeIcons.percent,
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPercentage = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: primaryTextColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secondaryTextColor),
        filled: true,
        fillColor: screenBackgroundColor.withOpacity(0.7),
        prefixIcon:
        Icon(icon, color: primaryColor.withOpacity(0.8), size: 20),
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
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: _resultColor.withOpacity(0.1), // Background based on result
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _resultColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(_resultIcon, color: _resultColor, size: 36),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _resultMessage,
              style: TextStyle(
                color: _resultColor.darken(0.2), // Darken for better contrast
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper extension for darkening colors (optional, but good for text on light backgrounds)
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
