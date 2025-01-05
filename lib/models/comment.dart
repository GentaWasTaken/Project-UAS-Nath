import 'package:http/http.dart' as http;
import 'dart:convert';

class Comment {
  final int id;
  final String username;
  final String book_id;
  final String content;

  Comment({
    required this.id,
    required this.username,
    required this.book_id,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      username: json['user']['name'],
      book_id: json['book_id'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'book_id': book_id,
      'content': content,
    };
  }

//   static Future<List<Book>> fethBooks() async {
//     const url = 'http://192.168.94.155:8000/api/books';
//     final response = await http.get(Uri.parse(url));
//     final Map<String, dynamic> data = json.decode(response.body);

//     if (data['success'] == true) {
//       {
//         final List<dynamic> booksJson = data['data'];
//         return booksJson.map((json) => Book.fromJson(json)).toList();
//       }
//     } else {
//       throw Exception('Gagal untuk menunjukkan buku');
//     }
//   }

//   static Future<void> getBook(int bookId) async {
//     final url = 'http://192.168.94.155:8000/api/books/$bookId';
//     final response = await http.get(Uri.parse(url));
//     final Map<String, dynamic> data = json.decode(response.body);
//     if (data['success'] == true) {
//       {
//         final Map<String, dynamic> bookJson = json.decode(response.body);
//       }
//     } else {
//       throw Exception('Gagal untuk menghapus buku');
//     }
//   }
}
