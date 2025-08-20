import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'social_categories.dart'; // import data

class SocialMediaScreen extends StatefulWidget {
  const SocialMediaScreen({super.key});

  @override
  State<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends State<SocialMediaScreen> {
  List<Map<String, dynamic>> filteredCategories = List.from(socialCategories);
  Map<String, dynamic>? selectedCategory;
  bool sortAscending = true;
  TextEditingController searchController = TextEditingController();

  void searchCategories(String query) {
    final results = socialCategories.where((cat) {
      final name = cat['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredCategories = results);
  }

  void sortCategories() {
    setState(() {
      filteredCategories.sort((a, b) => sortAscending
          ? a['name'].toString().compareTo(b['name'].toString())
          : b['name'].toString().compareTo(a['name'].toString()));
      sortAscending = !sortAscending;
    });
  }

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  void showInfoMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add More Pages'),
        content: const Text(
          'If you know any influencers, meme pages, or official college channels, feel free to send them to me. '
              'I can list them in the app to make it even more complete!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Social Media'),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(sortAscending ? Icons.sort_by_alpha : Icons.sort),
            onPressed: sortCategories,
            tooltip: sortAscending ? 'Sort A-Z' : 'Sort Z-A',
            color: Colors.grey[800],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 4,
              child: TextField(
                controller: searchController,
                onChanged: searchCategories,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  border: InputBorder.none,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedCategory == null
            ? GridView.builder(
          itemCount: filteredCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final category = filteredCategories[index];
            return GestureDetector(
              onTap: () {
                setState(() => selectedCategory = category);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: category['color'],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'],
                        size: 40, color: Colors.grey[800]),
                    const SizedBox(height: 12),
                    Text(
                      category['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() => selectedCategory = null);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Categories'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: selectedCategory!['pages'].length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1),
                itemBuilder: (context, index) {
                  final page = selectedCategory!['pages'][index];
                  return GestureDetector(
                    onTap: () => openLink(page['url']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(page['icon'],
                              size: 40, color: Colors.grey[800]),
                          const SizedBox(height: 12),
                          Text(
                            page['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showInfoMessage,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.info_outline),
        tooltip: 'Add more pages',
      ),
    );
  }
}
