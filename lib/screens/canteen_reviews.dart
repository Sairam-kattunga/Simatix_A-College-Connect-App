import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For more icon options
import 'package:shimmer/shimmer.dart'; // For loading shimmer effect

class FoodReviewScreen extends StatefulWidget {
  const FoodReviewScreen({super.key});

  @override
  State<FoodReviewScreen> createState() => _FoodReviewScreenState();
}

class _FoodReviewScreenState extends State<FoodReviewScreen> {
  final String dataUrl =
      "https://script.google.com/macros/s/AKfycbwPUcxwSPVWma6qe8YWjS7_OwO8t09Q6iTFpX4QCGsxrq3kIovsRzSz1OnSWiA6gE8Q/exec";

  final String formUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSd8XbWMYK-da5jTD4cPwUkXTV-wA0MqMCbqKuffGovG9NdtVA/viewform?usp=dialog";

  // --- Style Constants ---
  static const Color primaryColor = Color(0xFFFFA726); // Warm Orange - Appetizing
  static const Color accentColor = Color(0xFFFF7043); // Deeper Orange/Coral
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey Background
  static const Color cardColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF424242); // Dark Grey
  static const Color secondaryTextColor = Color(0xFF757575); // Medium Grey
  static const Color starColor = Colors.amber;
  static const Color iconThemeColor = Colors.white;


  List<dynamic> allReviews = [];
  Map<String, List<dynamic>> restaurantMap = {};
  String? selectedRestaurant; // Nullable to handle initial state better
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final res = await http.get(Uri.parse(dataUrl));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isEmpty) {
          setState(() {
            allReviews = [];
            restaurantMap = {};
            selectedRestaurant = null;
            isLoading = false;
            errorMessage = "No reviews found at the moment.";
          });
          return;
        }

        final Map<String, List<dynamic>> tempMap = {};
        for (var review in data) {
          final restaurant = review['Restaurant ']?.toString().trim();
          if (restaurant != null && restaurant.isNotEmpty) {
            if (!tempMap.containsKey(restaurant)) tempMap[restaurant] = [];
            tempMap[restaurant]!.add(review);
          }
        }

        setState(() {
          allReviews = data;
          restaurantMap = tempMap;
          if (tempMap.isNotEmpty) {
            selectedRestaurant = tempMap.keys.first;
          } else {
            selectedRestaurant = null;
            errorMessage = "No restaurants found with reviews.";
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reviews (Status: ${res.statusCode})');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching reviews: ${e.toString()}';
        selectedRestaurant = null; // Ensure no restaurant is selected on error
      });
      if (mounted) { // Check if widget is still in tree
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!), backgroundColor: Colors.redAccent));
      }
    }
  }

  double getAverageRating(List<dynamic> reviews, String itemName) {
    final itemReviews = reviews
        .where((r) => r['Item Name']?.toString().trim() == itemName)
        .toList();
    if (itemReviews.isEmpty) return 0.0;

    double sum = 0.0;
    int count = 0;
    for (var r in itemReviews) {
      final rating = double.tryParse(r['  Rating  ']?.toString() ?? '0.0');
      if (rating != null) {
        sum += rating;
        count++;
      }
    }
    return count > 0 ? sum / count : 0.0;
  }

  int getReviewCount(List<dynamic> reviews, String itemName) {
    return reviews
        .where((r) => r['Item Name']?.toString().trim() == itemName)
        .length;
  }

  void showItemReviewsDialog(String itemName, List<dynamic> reviews) {
    final itemReviews = reviews
        .where((r) => r['Item Name']?.toString().trim() == itemName)
        .toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cardColor,
        elevation: 8,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70% of screen height
            maxWidth: 500, // Max width for larger screens
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                itemName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              const SizedBox(height: 8),
              if (itemReviews.isEmpty)
                const Expanded(
                  child: Center(
                      child: Text("No reviews for this item yet.",
                          style: TextStyle(color: secondaryTextColor, fontSize: 16))),
                )
              else
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true, // Important for Column inside Dialog
                    itemCount: itemReviews.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey[300], height: 20),
                    itemBuilder: (context, index) {
                      final review = itemReviews[index];
                      final ratingVal = double.tryParse(review['  Rating  ']?.toString() ?? '0.0') ?? 0.0;
                      final text = review['  Review  ']?.toString() ?? 'No comment';
                      final dateString = review['Date']?.toString();
                      String formattedDate = 'Date not available';
                      if (dateString != null) {
                        try {
                          formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
                        } catch (e) {
                          // Handle parsing error if date is not in expected format
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: accentColor.withOpacity(0.9),
                              child: Text(
                                ratingVal.toStringAsFixed(0), // Show rating as whole number
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    text.isNotEmpty ? '"$text"' : 'No comment provided',
                                    style: TextStyle(fontSize: 15, color: primaryTextColor, fontStyle: text.isNotEmpty ? FontStyle.italic : FontStyle.normal),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchFormUrl() async {
    final uri = Uri.parse(formUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $formUrl';
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Cannot open form: $e'), backgroundColor: Colors.redAccent,));
      }
    }
  }

  Widget _buildStarRating(double rating, {double size = 18}) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star_rounded, color: starColor, size: size));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half_rounded, color: starColor, size: size));
      } else {
        stars.add(Icon(Icons.star_border_rounded, color: starColor.withOpacity(0.7), size: size));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Canteen Reviews', style: TextStyle(fontWeight: FontWeight.bold, color: iconThemeColor)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: iconThemeColor), // For back button etc.
        elevation: 3,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 20),
            tooltip: 'Refresh Reviews',
            onPressed: fetchReviews,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlsSection(),
          if (isLoading)
            Expanded(child: _buildLoadingShimmer())
          else if (errorMessage != null)
            Expanded(
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: secondaryTextColor, fontSize: 17)),
                    )))
          else if (selectedRestaurant == null || restaurantMap[selectedRestaurant]?.isEmpty == true)
              Expanded(
                  child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            selectedRestaurant == null
                                ? "Please select a restaurant to view reviews."
                                : "No reviews found for ${selectedRestaurant!}.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: secondaryTextColor, fontSize: 17)
                        ),
                      )))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: {
                    for (var r in restaurantMap[selectedRestaurant]!)
                      r['Item Name']?.toString().trim()
                  }
                      .where((itemName) => itemName != null && itemName.isNotEmpty) // Filter out empty or null item names
                      .length,
                  itemBuilder: (context, index) {
                    final uniqueItemNames = {
                      for (var r in restaurantMap[selectedRestaurant]!)
                        r['Item Name']?.toString().trim()
                    }
                        .where((itemName) => itemName != null && itemName.isNotEmpty)
                        .toList();

                    final itemName = uniqueItemNames[index];
                    if (itemName == null) return const SizedBox.shrink(); // Should not happen due to filter

                    final avgRating = getAverageRating(
                        restaurantMap[selectedRestaurant]!, itemName);
                    final reviewCount = getReviewCount(
                        restaurantMap[selectedRestaurant]!, itemName);

                    return _buildFoodItemCard(itemName, avgRating, reviewCount);
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchFormUrl,
              icon: const Icon(FontAwesomeIcons.penToSquare, size: 18, color: iconThemeColor),
              label: const Text('Add Your Review', style: TextStyle(fontSize: 16, color: iconThemeColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (restaurantMap.isNotEmpty)
            DropdownButtonFormField<String>(
              value: selectedRestaurant,
              items: restaurantMap.keys
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: primaryTextColor)),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedRestaurant = val);
                }
              },
              decoration: InputDecoration(
                labelText: 'Select Canteen/Restaurant',
                labelStyle: const TextStyle(color: primaryColor),
                filled: true,
                fillColor: backgroundColor.withOpacity(0.7),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor, width: 1.5)),
                prefixIcon: const Icon(FontAwesomeIcons.store, color: primaryColor, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
              isExpanded: true,
              hint: const Text("Select a Canteen", style: TextStyle(color: secondaryTextColor)),
            )
          else if (!isLoading) // Show a message if no restaurants but not loading
            const Text("No canteens available for selection.", style: TextStyle(color: secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(String itemName, double avgRating, int reviewCount) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor,
      shadowColor: primaryColor.withOpacity(0.3),
      child: InkWell(
        onTap: () => showItemReviewsDialog(itemName, restaurantMap[selectedRestaurant]!),
        borderRadius: BorderRadius.circular(15),
        splashColor: primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Placeholder for Food Item Image/Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    _getFoodIcon(itemName), // Dynamic icon based on item name
                    size: 30,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStarRating(avgRating, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 15,
                              color: primaryTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withOpacity(0.8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to get a somewhat relevant icon based on item name (can be expanded)
  IconData _getFoodIcon(String itemName) {
    String lowerItemName = itemName.toLowerCase();
    if (lowerItemName.contains('pizza')) return FontAwesomeIcons.pizzaSlice;
    if (lowerItemName.contains('burger')) return FontAwesomeIcons.burger;
    if (lowerItemName.contains('coffee') || lowerItemName.contains('tea')) return FontAwesomeIcons.mugHot;
    if (lowerItemName.contains('juice') || lowerItemName.contains('drink')) return FontAwesomeIcons.martiniGlass;
    if (lowerItemName.contains('rice') || lowerItemName.contains('biryani')) return FontAwesomeIcons.bowlRice;
    if (lowerItemName.contains('cake') || lowerItemName.contains('pastry')) return FontAwesomeIcons.cakeCandles;
    if (lowerItemName.contains('ice cream')) return FontAwesomeIcons.iceCream;
    if (lowerItemName.contains('sandwich')) return FontAwesomeIcons.bacon; // Closest for sandwich type
    return FontAwesomeIcons.utensils; // Default
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Number of shimmer items
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white, // Shimmer requires a solid color under it
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 18, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 16, color: Colors.white),
                      const SizedBox(height: 5),
                      Container(width: 80, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

