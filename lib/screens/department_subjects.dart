import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final List<Map<String, dynamic>> departments = [
  {
    'name': 'AGRI',
    'icon': Icons.agriculture,
    'reg2021': 'https://drive.google.com/file/d/1i8FFYdbds0EqZ-zl_wCiFhPKantloE6O/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1ndKA57HviiP5jrBOM9YG9ZobH8hwFSoZ/view?usp=drive_link',
  },
  {
    'name': 'AI & DS',
    'icon': Icons.computer,
    'reg2021': 'https://drive.google.com/file/d/1rBC--Gco7gabHvZXqvTA_bvJInl2dXu5/view?usp=drive_link',
    'reg2019': null,
  },
  {
    'name': 'AI & ML',
    'icon': Icons.smart_toy,
    'reg2021': 'https://drive.google.com/file/d/1oxdLoojVUidzl-Rc-opS8Eqni2P8fyhH/view?usp=drive_link',
    'reg2019': null,
  },
  {
    'name': 'AUTO',
    'icon': Icons.settings,
    'reg2021': 'https://drive.google.com/file/d/1uHVt_MswjfoxpGzNOr_ss_dUlZ14VtqY/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1FMVY0f8nCE8vtWFPqVRDiG_irlfHZzsB/view?usp=drive_link',
  },
  {
    'name': 'BI',
    'icon': Icons.biotech,
    'reg2021': 'https://drive.google.com/file/d/11ggWMKcjRgQVi65R7f0_KJq-y70A40py/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1dTTqcXccsIlEZnWe1DPUTHJL6_mCUoCS/view?usp=drive_link',
  },
  {
    'name': 'BME',
    'icon': Icons.medical_services,
    'reg2021': 'https://drive.google.com/file/d/1eZvkPQxUjq67qH98jlztQTNEl-ds8o7g/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1LNOiB2xeh4aAo6jiEvX6XJsXNt924Bj7/view?usp=drive_link',
  },
  {
    'name': 'BT',
    'icon': Icons.science,
    'reg2021': 'https://drive.google.com/file/d/1wmFqv99as3z8GCV4OSFlW5HsFfJEKAVz/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/138jZvmANP9g-lwsj7gar_FWhWVcGKKCF/view?usp=drive_link',
  },
  {
    'name': 'CIVIL',
    'icon': Icons.account_tree,
    'reg2021': 'https://drive.google.com/file/d/1PEDhdxPN-QsaKgIWDgm8QqWVMtcWre_S/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1v93Lv8ZJLwpEFgR_OpDx8wQtR8-teI8D/view?usp=drive_link',
  },
  {
    'name': 'CSE',
    'icon': Icons.code,
    'reg2021': 'https://drive.google.com/file/d/16EyhrALy4noGeSbnntHP8QZYOjjWn9JY/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1mKKxVdqXCwNnHv2392clOGyZajJU390k/view?usp=drive_link',
  },
  {
    'name': 'ECE',
    'icon': Icons.electrical_services,
    'reg2021': 'https://drive.google.com/file/d/1zt7p3GAV0ATvsYhIM2OCF8djBbPv-JRa/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1AChRWcoJGaf86yNPNg5U7lrCIlqOjx8/view?usp=drive_link',
  },
  {
    'name': 'EEE',
    'icon': Icons.electric_bolt,
    'reg2021': 'https://drive.google.com/file/d/1ElAEbK_r2uRnNh8FjM9saWk5DOoeUC9R/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1yFAx_zrfpuPvL2GSHKf5QqVwYABjXURL/view?usp=drive_link',
  },
  {
    'name': 'EnEE',
    'icon': Icons.electrical_services,
    'reg2021': 'https://drive.google.com/file/d/1zoXKPLCO6sUb5O8F_EiRa_dIIMrraUW9/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/1f-i8zUzyKTHqEH7CI9TmOLfhH0UdGgrt/view?usp=drive_link',
  },
  {
    'name': 'IT',
    'icon': Icons.desktop_mac,
    'reg2021': 'https://drive.google.com/file/d/1DEWVg-oi5FYPMWdNxeSMdQh2tsmWK5fF/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/17pMRAJAEyR7wPJ51HttdupJPebK9-x/view?usp=drive_link',
  },
  {
    'name': 'MECH',
    'icon': Icons.precision_manufacturing,
    'reg2021': 'https://drive.google.com/file/d/1VoEfOwfQ-w3hYHpWNgXpEbDxErXD8rwx/view?usp=drive_link',
    'reg2019': 'https://drive.google.com/file/d/17v84QdwBuc_b2CM-04jpSTSmEvQH_pG/view?usp=drive_link',
  },
];

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> filteredDepartments = List.from(departments);
  bool sortAscending = true;
  TextEditingController searchController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Map<String, dynamic>? selectedDepartment;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeOutBack);
  }

  void searchDepartments(String query) {
    final results = departments.where((dep) {
      final name = dep['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredDepartments = results);
  }

  void sortDepartments() {
    setState(() {
      filteredDepartments.sort((a, b) => sortAscending
          ? a['name'].toString().compareTo(b['name'].toString())
          : b['name'].toString().compareTo(a['name'].toString()));
      sortAscending = !sortAscending;
    });
  }

  Future<void> openLink(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }
  void showUnavailableMessage(String regYear) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text('$regYear Not Available', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('The selected regulation is currently unavailable.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showRegulations(Map<String, dynamic> department) async {
    setState(() => selectedDepartment = department);
    await _animationController?.forward();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ScaleTransition(
        scale: _scaleAnimation!,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  department['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (department['reg2021'] != null) {
                      openLink(department['reg2021']);
                    } else {
                      showUnavailableMessage('Regulation 2021');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Regulation 2021', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (department['reg2019'] != null) {
                      openLink(department['reg2019']);
                    } else {
                      showUnavailableMessage('Regulation 2019');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Regulation 2019', style: TextStyle(color: Colors.white)),
                ),


                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _animationController?.reverse();
                  },
                  child: const Text('Close', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  final List<Color> tileColors = [
    Colors.teal.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.green.shade100,
    Colors.cyan.shade100,
    Colors.amber.shade100,
    Colors.lime.shade100,
    Colors.pink.shade100,
    Colors.indigo.shade100,
    Colors.deepOrange.shade100,
    Colors.blueGrey.shade100,
    Colors.lightGreen.shade100,
    Colors.brown.shade100,
    Colors.deepPurple.shade100,
    Colors.blue.shade100,
  ];

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(sortAscending ? Icons.sort_by_alpha : Icons.sort),
            onPressed: sortDepartments,
            tooltip: sortAscending ? 'Sort A-Z' : 'Sort Z-A',
            color: Colors.grey[800],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                onChanged: searchDepartments,
                decoration: InputDecoration(
                  hintText: 'Search departments...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),

        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDepartments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final dep = filteredDepartments[index];
          final color = tileColors[index % tileColors.length]; // rotate colors
          return GestureDetector(
            onTap: () => showRegulations(dep),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(dep['icon'], size: 40, color: Colors.grey[800]),
                  const SizedBox(height: 12),
                  Text(
                    dep['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
