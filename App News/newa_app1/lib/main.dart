import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Main function: Start the app
void main() {
  runApp(const MyApp());
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'News App',
      home: const NewsHomePage(),
    );
  }
}

// Home page widget
class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  List articles = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  String selectedCategory = 'general';
  bool isDarkMode = false;
  bool _isSearchBarVisible = false; // Control search bar visibility
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Categories
  final List<String> categories = [
    'general',
    'sports',
    'entertainment',
    'business',
    'technology',
    'health',
    'science'
  ];

  // NewsAPI key
  final String apiKey = '62b223f0d5734b7eb4d253877f72b65a';

  @override
  void initState() {
    super.initState();
    loadTheme();
    fetchNews(category: selectedCategory);
    // Listen for focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        print('Search bar focused: ${_searchFocusNode.hasFocus}'); // Debug log
      });
    });
  }

  // Load theme preference
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save theme preference
  Future<void> saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Toggle theme
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      saveTheme(isDarkMode);
      print('Theme changed to: ${isDarkMode ? "Dark" : "Light"}'); // Debug log
    });
  }

  // Fetch news from NewsAPI
  Future<void> fetchNews({String query = '', String category = 'general'}) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String url = query.isNotEmpty
          ? 'https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey'
          : 'https://newsapi.org/v2/top-headlines?country=us&category=$category&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url));
      print('API Response: ${response.statusCode}'); // Debug log
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            articles = data['articles'] ?? [];
            isLoading = false;
            errorMessage = '';
            print('Fetched news for category: $category, query: $query'); // Debug log
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Failed to load news';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Fetch Error: $e'); // Debug log
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  // Open article in browser
  Future<void> openArticle(String? url) async {
    if (url == null || url.isEmpty) {
      setState(() {
        errorMessage = 'Invalid article URL';
      });
      return;
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      setState(() {
        errorMessage = 'Could not open article';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set AppBar height based on search bar visibility
    final double appBarHeight = _isSearchBarVisible ? 90.0 : 64.0;

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            backgroundColor: isDarkMode ? Colors.blueGrey[800] : Colors.blue, // Header color
            title: Row(
              children: [
                const Text(
                  'News App',
                  style: TextStyle(fontSize: 20, color: Colors.white), // Increased title size
                ),
                if (_isSearchBarVisible) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search news...',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9), // White fill for contrast
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      onSubmitted: (value) {
                        setState(() {
                          searchQuery = value.trim();
                          fetchNews(query: searchQuery, category: selectedCategory);
                          print('Search submitted: $searchQuery'); // Debug log
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              // Search icon toggles search bar visibility
              IconButton(
                icon: Icon(
                  _isSearchBarVisible ? Icons.search_off : Icons.search,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_isSearchBarVisible && _searchController.text.isNotEmpty) {
                      // If search bar is visible and has text, trigger search
                      searchQuery = _searchController.text.trim();
                      fetchNews(query: searchQuery, category: selectedCategory);
                      print('Search triggered: $searchQuery'); // Debug log
                    } else {
                      // Toggle search bar visibility
                      _isSearchBarVisible = !_isSearchBarVisible;
                      if (_isSearchBarVisible) {
                        _searchFocusNode.requestFocus();
                      } else {
                        _searchController.clear();
                        searchQuery = '';
                        fetchNews(category: selectedCategory);
                      }
                      print('Search bar visibility: $_isSearchBarVisible, AppBar height: $appBarHeight'); // Debug log
                    }
                  });
                },
                padding: const EdgeInsets.all(4.0), // Tight spacing
                constraints: const BoxConstraints(), // Remove default padding
              ),
              // Clear icon when search bar is visible and has text
              if (_isSearchBarVisible && _searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                      fetchNews(category: selectedCategory);
                      print('Search cleared'); // Debug log
                    });
                  },
                  padding: const EdgeInsets.all(4.0), // Tight spacing
                  constraints: const BoxConstraints(), // Remove default padding
                ),
              // Theme toggle
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: toggleTheme,
                padding: const EdgeInsets.all(4.0), // Tight spacing
                constraints: const BoxConstraints(), // Remove default padding
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category buttons
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                          _searchController.clear();
                          searchQuery = '';
                          _isSearchBarVisible = false; // Hide search bar on category tap
                          fetchNews(category: selectedCategory);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? (isDarkMode ? Colors.blueGrey : Colors.blue)
                            : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      child: Text(
                        category[0].toUpperCase() + category.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Top News Carousel
            if (!isLoading && errorMessage.isEmpty && articles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Top News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.8,
                      ),
                      items: articles.take(5).map((article) {
                        return GestureDetector(
                          onTap: () => openArticle(article['url']),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: article['urlToImage'] != null
                                      ? Image.network(
                                    article['urlToImage'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 180,
                                      color: Theme.of(context).cardColor,
                                      child: const Icon(Icons.broken_image, size: 40),
                                    ),
                                  )
                                      : Container(
                                    height: 180,
                                    color: Theme.of(context).cardColor,
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [Colors.black54, Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 6,
                                  left: 6,
                                  right: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article['title'] ?? 'No Title',
                                        style: const TextStyle(fontSize: 14, color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        article['source']['name'] ?? 'Unknown',
                                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            // News list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage, style: const TextStyle(fontSize: 14, color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => fetchNews(query: searchQuery, category: selectedCategory),
                      child: const Text('Retry', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              )
                  : articles.isEmpty
                  ? const Center(child: Text('No news found', style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return GestureDetector(
                    onTap: () => openArticle(article['url']),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: article['urlToImage'] != null
                                ? Image.network(
                              article['urlToImage'],
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 150,
                                color: Theme.of(context).cardColor,
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            )
                                : Container(
                              height: 150,
                              color: Theme.of(context).cardColor,
                              child: const Icon(Icons.image, size: 40),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article['title'] ?? 'No Title',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  article['description'] ?? 'No Description',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  article['source']['name'] ?? 'Unknown',
                                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                                ),
                              ],
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
    );
  }
}