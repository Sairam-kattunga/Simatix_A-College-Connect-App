import 'package:flutter/material.dart';

class CollegeRulesScreen extends StatefulWidget {
  const CollegeRulesScreen({super.key});

  @override
  State<CollegeRulesScreen> createState() => _CollegeRulesScreenState();
}

class _CollegeRulesScreenState extends State<CollegeRulesScreen> {
  TextEditingController searchController = TextEditingController();

  // Categories only with icons & colors
  final List<Map<String, dynamic>> ruleCategories = [
    {'title': 'Academic Rules', 'icon': Icons.school, 'color': Colors.blue.shade100},
    {'title': 'Hostel Rules', 'icon': Icons.home, 'color': Colors.orange.shade100},
    {'title': 'Library & Lab Rules', 'icon': Icons.local_library, 'color': Colors.green.shade100},
    {'title': 'Sports & Events', 'icon': Icons.sports_soccer, 'color': Colors.purple.shade100},
    {'title': 'Code of Conduct', 'icon': Icons.rule, 'color': Colors.red.shade100},
  ];

  List<Map<String, dynamic>> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = List.from(ruleCategories);
  }

  void searchCategories(String query) {
    final results = ruleCategories.where((cat) {
      final title = cat['title'].toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();
    setState(() => filteredCategories = results);
  }

  void showPlaceholderMessage(String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text(
          "This section is yet to be developed. If you have any ideas or suggestions, feel free to reach out!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Rules'),
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(4),
              child: TextField(
                controller: searchController,
                onChanged: searchCategories,
                decoration: InputDecoration(
                  hintText: 'Search rules...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return GestureDetector(
                  onTap: () => showPlaceholderMessage(category['title']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: category['color'],
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
                        Icon(category['icon'], size: 40, color: Colors.black87),
                        const SizedBox(height: 12),
                        Text(
                          category['title'],
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
          ),
        ],
      ),
    );
  }
}
