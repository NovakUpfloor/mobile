// Penjelasan:
// Repository ini mengelola semua logika terkait data autentikasi.
// - Berinteraksi dengan ApiClient untuk login/register.
// - Menggunakan FlutterSecureStorage untuk menyimpan/menghapus token.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waisaka_property/core/api/api_client.dart';
import 'package:waisaka_property/features/auth/data/models/package_model.dart';
import 'package:waisaka_property/features/auth/data/models/user.dart';

class AuthRepository {
 final ApiClient _apiClient;
 final FlutterSecureStorage _secureStorage;

 AuthRepository({
   required ApiClient apiClient,
   required FlutterSecureStorage secureStorage,
 })  : _apiClient = apiClient,
       _secureStorage = secureStorage;

 Future<List<Package>> getPackages() async {
   final response = await _apiClient.get('/packages');
   final data = response['data'] as List;
   return data.map((json) => Package.fromJson(json)).toList();
 }

 Future<void> register({
   required String name,
   required String username,
   required String email,
   required String password,
   required int? packageId,
 }) async {
   await _apiClient.post('/auth/register', body: {
     'nama': name,
     'username': username,
     'email': email,
     'password': password,
     // Backend Anda mungkin memerlukan package_id saat registrasi
     // 'package_id': packageId, 
   });
 }

 Future<User> login({required String username, required String password}) async {
   final response = await _apiClient.post('/auth/login', body: {
     'username': username,
     'password': password,
   });
   final token = response['token'];
   await _secureStorage.write(key: 'auth_token', value: token);
   return User.fromJson(response['user']);
 }

 Future<void> logout() async {
   await _apiClient.post('/auth/logout', body: {});
   await _secureStorage.delete(key: 'auth_token');
 }

 Future<String?> getToken() async {
   return await _secureStorage.read(key: 'auth_token');
 }

 Future<User> getUserProfile() async {
   final response = await _apiClient.get('/dashboard/profile');
   return User.fromJson(response['data']);
 }
}