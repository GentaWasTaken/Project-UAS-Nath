import 'dart:convert';

import 'package:project_uas/models/book.dart';
import 'package:flutter/material.dart';
import 'package:project_uas/data/candi_data.dart';
import 'package:project_uas/widget/item_card.dart';

import '../utils/GentaRequest.dart';
import '../utils/LocalStorageManager.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<dynamic> _products = [];

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
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });
      String? mToken = await LocalStorageManager().getString(LOGIN_TOKEN);
      http.Response? res = await GentaRequest().get("/books", mToken!);
      setState(() {
        _isLoading = false;
      });

      if (res != null && res.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(res.body); // Decode JSON menjadi List
        setState(() {
          _products = data.map((json) => Book.fromJson(json)).toList();
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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('Images/project_uas.png'),
            ),
            SizedBox(height: 20),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0), // Padding untuk GridView
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ItemCard(
                    book: product, // Kirim data produk ke ItemCard
                  );
                },
              ),
            ),
    );
  }
}
