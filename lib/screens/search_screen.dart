import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_uas/utils/GentaRequest.dart';
import 'package:project_uas/utils/LocalStorageManager.dart';
import 'package:project_uas/screens/detail_screen.dart';

// Update the model import to use the correct model
import 'package:project_uas/models/book.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Declare variables
  List<Book> _products = []; // List of Book objects
  List<Book> filteredBooks = []; // List of filtered books
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // Fetch the list of products (books) from the API
  Future<void> fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });
      String? mToken = await LocalStorageManager().getString(LOGIN_TOKEN);
      http.Response? res = await GentaRequest()
          .get("/books", mToken!); // Change to correct endpoint for books
      setState(() {
        _isLoading = false;
      });

      if (res != null && res.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(res.body); // Decode JSON into List
        setState(() {
          _products = data
              .map((json) => Book.fromJson(json))
              .toList(); // Map to Book model
        });
      } else {
        _showDialog(context, 'Error', '${jsonDecode(res!.body)["data"]}');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isLoading = false;
      });
      _showDialog(context, 'Error', 'Connection timeout. Please try again.');
    }
  }

  // Show a dialog in case of error
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize search listener
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        filterBooks(); // Filter books based on search query
      });
    });
    fetchProducts(); // Fetch products when screen loads
  }

  // Filter books based on the search query
  void filterBooks() {
    setState(() {
      filteredBooks = _products
          .where((book) => book.judul
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) // Search by book title
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Buku'), // Updated title
      ),
      body: Column(
        children: [
          // TextField for search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color.fromARGB(255, 251, 251, 251),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Cari Buku', // Updated hint text
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // ListView of search results
          Expanded(
            child: ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                            book:
                                book), // Pass the selected book to detail screen
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 1, 1, 1),
                        width: 1,
                      ),
                    ),
                    color: const Color.fromARGB(255, 224, 198, 238),
                    elevation: 6,
                    shadowColor: Colors.purple.withOpacity(0.3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              book.foto, // Display the book's image
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.judul, // Display the book title
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    book.genre, // Display the book's genre
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Buku populer yang wajib dibaca.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
