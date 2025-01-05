import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:project_uas/models/book.dart';

import '../screens/detail_screen.dart';

class ItemCard extends StatelessWidget {
  // Deklarasi
  final Book book;

  const ItemCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(book: book),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: Color.fromARGB(255, 1, 1, 1), // Border warna lembut
            width: 1,
          ),
        ),
        color:
            const Color.fromARGB(255, 224, 198, 238), // Warna latar lebih cerah
        elevation: 6, // Efek bayangan lebih menonjol
        shadowColor: Colors.purple.withOpacity(0.3), // Warna bayangan
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0), // Padding lebih kecil
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Radius lebih kecil
                child: CachedNetworkImage(
                  imageUrl: book.foto,
                  width: 100, // Ukuran lebih proporsional
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child:
                        CircularProgressIndicator(), // Loader saat gambar diunduh
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50, // Placeholder error
                  ),
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
                        color: Colors.black87, // Warna teks lebih gelap
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100, // Warna latar label
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
                      book.deskripsi,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54, // Warna teks deskripsi
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
  }
}
