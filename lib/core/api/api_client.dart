// Penjelasan:
// Kelas ini adalah pusat untuk melakukan semua panggilan HTTP ke API backend.
// Fungsinya:
// 1. Mengelola base URL dan header default untuk setiap request.
// 2. Secara otomatis menyisipkan token autentikasi jika ada.
// 3. Menangani respons dari server dan error jaringan.

import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
 final FlutterSecureStorage _secureStorage;
 final String _baseUrl = dotenv.env['BASE_URL']!;

 ApiClient({required FlutterSecureStorage secureStorage}) : _secureStorage = secureStorage;

 Future<Map<String, String>> _getHeaders() async {
   final token = await _secureStorage.read(key: 'auth_token');
   return {
     'Content-Type': 'application/json; charset=UTF-8',
     'Accept': 'application/json',
     if (token != null) 'Authorization': 'Bearer $token',
   };
 }

 Future<dynamic> get(String endpoint) async {
   try {
     final response = await http.get(
       Uri.parse('$_baseUrl/api/v1$endpoint'),
       headers: await _getHeaders(),
     );
     return _processResponse(response);
   } on SocketException {
     throw Exception('Tidak ada koneksi internet.');
   } catch (e) {
     throw Exception('Terjadi kesalahan: $e');
   }
 }

 Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
   try {
     final response = await http.post(
       Uri.parse('$_baseUrl/api/v1$endpoint'),
       headers: await _getHeaders(),
       body: json.encode(body),
     );
     return _processResponse(response);
   } on SocketException {
     throw Exception('Tidak ada koneksi internet.');
   } catch (e) {
     throw Exception('Terjadi kesalahan: $e');
   }
 }

 dynamic _processResponse(http.Response response) {
   final responseBody = json.decode(response.body);
   if (response.statusCode >= 200 && response.statusCode < 300) {
     return responseBody;
   } else {
     // Menangani error validasi dari Laravel
     if (responseBody['errors'] != null) {
       final errors = responseBody['errors'] as Map<String, dynamic>;
       final firstError = errors.values.first[0];
       throw Exception(firstError);
     }
     throw Exception(responseBody['message'] ?? 'Terjadi kesalahan server.');
   }
 }
}