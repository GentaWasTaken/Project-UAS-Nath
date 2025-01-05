import 'package:project_uas/models/book.dart';
import 'package:project_uas/utils/LocalStorageManager.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_uas/models/comment.dart';
import 'package:project_uas/data/candi_data.dart';

class DetailScreen extends StatefulWidget {
  final Book book;
  const DetailScreen({super.key, required this.book});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false; // Status apakah buku ini favorit
  bool isSignedIn = false; // Status apakah pengguna sudah login
  List<Comment> _comments = []; // List komentar
  final TextEditingController _commentController =
      TextEditingController(); // Controller untuk input komentar;

  @override
  void initState() {
    super.initState();
    _checkSignStatus(); // Memeriksa status login pengguna
    _loadFavoriteStatus(); // Memuat status favorit dari SharedPreferences
  }

  Future<void> _loadComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'comments_${widget.book.judul.replaceAll(' ', '_')}';
    setState(() {
      _comments.add(Comment(
          id: 1,
          username: "Test",
          book_id: "00000",
          content: prefs.getString(key) ?? "Null!"));
    });
  }

  Future<void> _saveComment(String comment) async {
    if (comment.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'comments_${widget.book.judul.replaceAll(' ', '_')}';
    String? mUsernames = await LocalStorageManager().getString(LOGIN_USERNAME);

    setState(() {
      _comments.add(Comment(
          id: 1, username: mUsernames!, book_id: "00000", content: comment));
    });
    await prefs.setString(key, comment);
    _commentController.clear();
  }

  // Fungsi untuk memeriksa status login pengguna
  Future<void> _checkSignStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSignedIn = prefs.getBool('isSignedIn') ?? false; // Memuat status login
    });
  }

  // Fungsi untuk memuat status favorit buku dari SharedPreferences
  Future<void> _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key =
        'favorite_${widget.book.judul.replaceAll(' ', '_')}'; // Key untuk status favorit berdasarkan judul buku
    setState(() {
      isFavorite = prefs.getBool(key) ?? false; // Memuat status favorit
    });
  }

  // Fungsi untuk toggle status favorit
  Future<void> _toggleFavorite() async {
    if (!isSignedIn) {
      // Navigasi ke halaman login jika pengguna belum login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/signin');
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key =
        'favorite_${widget.book.judul.replaceAll(' ', '_')}'; // Key untuk status favorit berdasarkan judul buku
    setState(() {
      isFavorite = !isFavorite; // Toggle status favorit
    });
    await prefs.setBool(
        key, isFavorite); // Menyimpan status favorit ke SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: constraints.maxHeight < 600
                ? const BouncingScrollPhysics() // Scroll physics untuk tampilan layar kecil
                : const NeverScrollableScrollPhysics(), // Tidak ada scroll jika layar cukup besar
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraints
                      .maxHeight), // Menjaga agar tampilan selalu minimal
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Background
                      Container(
                        height: 300, // Tinggi latar belakang
                      ),
                      // Header buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 32), // Padding untuk tombol header
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(
                                  context), // Tombol untuk kembali
                              icon: const Icon(Icons.arrow_back),
                            ),
                            IconButton(
                              onPressed:
                                  _toggleFavorite, // Tombol untuk toggle favorit
                              icon: Icon(
                                isSignedIn && isFavorite
                                    ? Icons
                                        .favorite // Ikon favorit jika buku ini disukai
                                    : Icons
                                        .favorite_border, // Ikon border jika belum disukai
                                color: isSignedIn && isFavorite
                                    ? Colors
                                        .red // Warna merah jika buku disukai
                                    : null, // Tidak ada warna jika belum disukai
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Image and info
                      Positioned(
                        top: 100,
                        left: 16,
                        right: 16,
                        child: Card(
                          color: Color.fromARGB(
                              255, 180, 133, 215), // Warna latar belakang kartu
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16), // Membulatkan sudut kartu
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.book.foto, // Gambar buku
                                    width: 120,
                                    height: 180,
                                    fit: BoxFit
                                        .cover, // Menyesuaikan gambar agar sesuai dengan ukuran
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple[100]?.withOpacity(
                                          0.5), // Warna latar belakang dengan transparansi
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Detail Informasi", // Judul bagian informasi buku
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                color: Color.fromARGB(
                                                    255, 180, 133, 215),
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                  'Pengarang: ${widget.book.penulis}'), // Menampilkan pengarang buku
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.category,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                  'Kategori: ${widget.book.genre}'), // Menampilkan kategori buku
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deskripsi:", // Judul bagian deskripsi buku
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(widget
                            .book.deskripsi), // Menampilkan deskripsi buku
                        const SizedBox(height: 16),
                        const Text(
                          "Komentar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // Column(
                        //   children: _comments
                        //       .map((comment) => Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //                 vertical: 4.0),
                        //             child: Row(
                        //               children: [
                        //                 const Icon(
                        //                   Icons.comment,
                        //                   color: Colors.blue,
                        //                   size: 20,
                        //                 ),
                        //                 const SizedBox(width: 8),
                        //                 Expanded(child: Text(comment.username)),
                        //               ],
                        //             ),
                        //           ))
                        //       .toList(),
                        // ),
                        SizedBox(
                          height: 200, // Sesuaikan tinggi sesuai kebutuhan
                          child: ListView.builder(
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.comment,
                                        color: Colors.grey),
                                    title: Text(comment.username),
                                    subtitle: Text(comment.content),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: 'Tambahkan Komentar',
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                _saveComment(_commentController.text);
                              },
                            ),
                          ),
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
    );
  }
}
