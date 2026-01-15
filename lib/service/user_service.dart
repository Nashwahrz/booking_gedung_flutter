import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ModelUser.dart';

class UserService {
  static const String baseUrl = "http://10.57.107.139:3001/api/auth";

  Future<Map<String, dynamic>> register(Datum user) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode; // Tambahkan ini!
      return data;
    } catch (e) {
      return {"message": "Koneksi Gagal", "statusCode": 500};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode; // Tambahkan ini!
      return data;
    } catch (e) {
      return {"message": "Koneksi Gagal", "statusCode": 500};
    }
  }
}