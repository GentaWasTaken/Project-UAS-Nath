import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_uas/models/book.dart';
import 'package:project_uas/screens/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<Book> favorites;
  late List<Book> project_uas;

  @override
  void initState() {
    super.initState();
    favorites = [];
    project_uas = [];
    _loadBooks(); // Fetch books
  }

  Future<void> _loadBooks() async {
    final response = await http.get(Uri.parse(
        'https://api.example.com/books')); // Replace with your API URL

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        project_uas = data.map((bookJson) => Book.fromJson(bookJson)).toList();
      });
      _loadFavorites(); // Load favorites after books are fetched
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Book> tempFavorites = [];

    for (Book book in project_uas) {
      String key = 'favorite_${book.judul.replaceAll(' ', '_')}';
      bool isFavorite = prefs.getBool(key) ?? false;
      if (isFavorite) {
        tempFavorites.add(book);
      }
    }

    setState(() {
      favorites = tempFavorites;
    });

    await prefs.setInt('favoriteBookCount', tempFavorites.length);
  }

  Future<void> _toggleFavorite(Book book) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'favorite_${book.judul.replaceAll(' ', '_')}';
    bool currentStatus = prefs.getBool(key) ?? false;

    await prefs.setBool(key, !currentStatus);

    setState(() {
      book.isFavorite = !currentStatus; // Update the UI state
    });

    // Refresh favorite list after updating
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(255, 248, 242, 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: favorites.isEmpty
              ? const Center(child: Text('No favorites added yet'))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final book = favorites[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              book: book,
                            ),
                          ),
                        );
                        _loadFavorites();
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: const Color.fromARGB(
                                255, 1, 1, 1), // Border warna lembut
                            width: 1,
                          ),
                        ),
                        color: const Color.fromARGB(
                            255, 224, 198, 238), // Warna latar lebih cerah
                        elevation: 6, // Efek bayangan lebih menonjol
                        shadowColor:
                            Colors.purple.withOpacity(0.3), // Warna bayangan
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(
                                  12.0), // Padding lebih kecil
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    12), // Radius lebih kecil
                                child: Image.asset(
                                  book.foto,
                                  width: 100, // Ukuran lebih proporsional
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
                                      book.judul,
                                      style: const TextStyle(
                                        fontSize: 18, // Ukuran teks lebih besar
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .black87, // Warna teks lebih gelap
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple
                                            .shade100, // Warna latar label
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        book.genre,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Buku populer yang wajib dibaca.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .black54, // Warna teks deskripsi
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
      ),
    );
  }
}
