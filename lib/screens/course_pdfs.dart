import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursePDFsScreen extends StatefulWidget {
  const CoursePDFsScreen({super.key});

  @override
  State<CoursePDFsScreen> createState() => _CoursePDFsScreenState();
}

class _CoursePDFsScreenState extends State<CoursePDFsScreen> {
  final String dataUrl =
      "https://script.google.com/macros/s/AKfycby7nTuMpkyfgoCK9LDQDuDm8F7d4s31yPMrLzL4l0XDPwiUYI_L6lIYOXQduKPhedW9/exec";
  final String googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScYc0ej4dtYQNcJZxbGNbGpzHuW79C9pXiARSxclYQB3PxQ-Q/viewform?usp=dialog';

  List<dynamic> pdfList = [];
  List<dynamic> filteredList = [];
  bool isLoading = true;
  bool sortAscending = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPDFs();
  }

  Future<void> fetchPDFs() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(dataUrl));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          pdfList = data;
          filteredList = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load PDFs');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void searchPDFs(String query) {
    final results = pdfList.where((pdf) {
      final title = pdf['title'].toString().toLowerCase();
      final subject = pdf['subject'].toString().toLowerCase();
      return title.contains(query.toLowerCase()) ||
          subject.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredList = results);
  }

  void sortPDFs() {
    setState(() {
      filteredList.sort((a, b) => sortAscending
          ? a['title'].toString().toLowerCase().compareTo(
          b['title'].toString().toLowerCase())
          : b['title'].toString().toLowerCase().compareTo(
          a['title'].toString().toLowerCase()));
      sortAscending = !sortAscending;
    });
  }

  Future<void> openGoogleForm() async {
    final uri = Uri.parse(googleFormUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Form')),
      );
    }
  }

  Future<void> downloadPDF(String url, String fileName) async {
    double progress = 0.0;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName.pdf';
      final file = File(filePath);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text('Downloading $fileName.pdf'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text('${(progress * 100).toStringAsFixed(0)} %'),
              ],
            ),
          ),
        ),
      );

      final req = await HttpClient().getUrl(Uri.parse(url));
      final response = await req.close();
      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final bytes = <int>[];

      await for (var chunk in response) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        progress = receivedBytes / totalBytes;
        // update dialog
        (context as Element).markNeedsBuild();
      }

      await file.writeAsBytes(bytes);
      Navigator.pop(context); // Close progress dialog

      // Open / Close dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Download Complete'),
          content: Text('$fileName.pdf has been downloaded.'),
          actions: [
            TextButton(
              onPressed: () {
                OpenFile.open(filePath);
                Navigator.pop(context);
              },
              child: const Text('Open'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  Future<void> viewPDF(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course PDFs'),
        actions: [
          IconButton(
            tooltip: 'Add PDF',
            icon: const Icon(Icons.upload_file, color: Colors.green),
            onPressed: openGoogleForm,
          ),
          IconButton(
            tooltip: sortAscending ? "Sort A-Z" : "Sort Z-A",
            icon: Icon(
              sortAscending ? Icons.sort_by_alpha : Icons.sort,
            ),
            onPressed: sortPDFs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or subject',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: searchPDFs,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                ? const Center(child: Text("No PDFs found."))
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pdf = filteredList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Soft background instead of full blue
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      pdf['title'],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      pdf['subject'],
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Download',
                          icon: const Icon(Icons.download, color: Colors.blue),
                          onPressed: () => downloadPDF(pdf['url'], pdf['title']),
                        ),
                        IconButton(
                          tooltip: 'View',
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                          onPressed: () => viewPDF(pdf['url']),
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
