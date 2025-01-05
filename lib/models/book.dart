class Book {
  final int id;
  final String isbn;
  final String judul;
  final String penulis;
  final String penerbit;
  final String genre;
  final String deskripsi;
  final String foto;
  bool isFavorite = false;

  Book({
    required this.id,
    required this.isbn,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.genre,
    required this.deskripsi,
    required this.foto,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    print("FOTO1: ${json["foto"]}");
    return Book(
      id: json['id'] ?? 0,
      isbn: json['isbn'] ?? '',
      judul: json['judul'] ?? 'Tidak ada judul',
      penulis: json['penulis'] ?? 'Tidak ada penulis',
      penerbit: json['penerbit'] ?? 'Tidak ada penerbit',
      genre: json['genre'] ?? 'Tidak ada genre',
      deskripsi: json['deskripsi'] ?? 'Tidak ada deskripsi',
      foto: json['foto'] ?? '',
    );
  }
}
