// services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Impor semua model yang dibutuhkan
import '../models/property_model.dart';
import '../models/dashboard/dashboard_model.dart';
import '../models/property/property_detail_model.dart';
import '../config/constants.dart';

class ApiService {
  // --- FUNGSI AUTENTIKASI ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('user')) {
        return responseData;
      } else {
        throw Exception('Format respons login tidak sesuai.');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Login Gagal');
    }
  }

  Future<String> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({
        'nama': name,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      // 201 Created
      return responseData['message'];
    } else {
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first[0];
        throw Exception(firstError);
      }
      throw Exception(responseData['message'] ?? 'Pendaftaran gagal.');
    }
  }

  // --- FUNGSI PROPERTI ---
  Future<List<Property>> fetchProperties() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/properties'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data']['data'];

        List<Property> properties = [];
        for (var item in data) {
          final imageResponse = await http.get(
            Uri.parse('$apiBaseUrl/properties/${item['id_property']}'),
          );
          String? firstImage;
          if (imageResponse.statusCode == 200) {
            final detailBody = json.decode(imageResponse.body);
            if (detailBody['data']['images'] != null &&
                detailBody['data']['images'].isNotEmpty) {
              firstImage = detailBody['data']['images'][0]['gambar'];
            }
          }
          properties.add(Property.fromJson(item, firstImage));
        }
        return properties;
      } else {
        throw Exception(
          'Gagal memuat daftar properti: Status Code ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Error: $e');
    }
  }

  Future<PropertyDetail> fetchPropertyDetails(int propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/properties/$propertyId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return PropertyDetail.fromJson(body['data']);
      } else {
        throw Exception(
          'Gagal memuat detail properti: Status Code ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Error: $e');
    }
  }

  Future<List<Property>> searchProperties(Map<String, dynamic> filters) async {
    try {
      Uri uri = Uri.parse('$apiBaseUrl/properties/search').replace(
        queryParameters: {
          'location': filters['location']?.toString(),
          'type': filters['type']?.toString(),
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data']['data'];

        List<Property> properties = [];
        for (var item in data) {
          final imageResponse = await http.get(
            Uri.parse('$apiBaseUrl/properties/${item['id_property']}'),
          );
          String? firstImage;
          if (imageResponse.statusCode == 200) {
            final detailBody = json.decode(imageResponse.body);
            if (detailBody['data']['images'] != null &&
                detailBody['data']['images'].isNotEmpty) {
              firstImage = detailBody['data']['images'][0]['gambar'];
            }
          }
          properties.add(Property.fromJson(item, firstImage));
        }
        return properties;
      } else {
        throw Exception(
          'Gagal melakukan pencarian: Status Code ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Error: $e');
    }
  }

  // --- FUNGSI DASBOR ---
  Future<DashboardData> fetchDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return DashboardData.fromJson(body['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir.');
      } else {
        throw Exception(
          'Gagal memuat data dasbor: Status Code ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server untuk data dasbor. Error: $e');
    }
  }
}
