import 'dart:convert';
import 'package:http/http.dart' as http;

const String API_URL = "http://192.168.1.17:8000/api";
const String ROOT_URL = "http://192.168.1.17:8000/";

class GentaRequest {
  static final GentaRequest _instance = GentaRequest._internal();

  factory GentaRequest() => _instance;

  GentaRequest._internal();

  String getPathFoto(String? data) {
    return "$ROOT_URL$data";
  }

  Future<http.Response?> get(String m_url, String token) async {
    var url = Uri.parse("$API_URL$m_url");
    print('$API_URL$m_url');
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      print(" RES: ${response.body} CODE: ${response.statusCode}");
      if (response.statusCode == 200) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }

  Future<http.Response?> patch(
      String m_url, String token, Map<String, String> body) async {
    var url = Uri.parse("$API_URL$m_url");
    print("REQ TO $m_url with token: $token");
    try {
      var response = await http
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }

  Future<http.Response?> post(
      String m_url, String token, Map<String, String> body) async {
    var url = Uri.parse("$API_URL$m_url");
    print("REQ TO $m_url with token: $token");
    try {
      var response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }
}
