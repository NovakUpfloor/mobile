// Penjelasan:
// Repository untuk fitur Properti. Mengambil data properti dari API.

import 'package:waisaka_property/core/api/api_client.dart';
import 'package:waisaka_property/features/property/data/models/property_model.dart';

class PropertyRepository {
 final ApiClient _apiClient;

 PropertyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

 Future<List<Property>> getProperties() async {
   try {
     final response = await _apiClient.get('/properties');
     final data = response['data']['data'] as List;
     // Di sini kita perlu logika tambahan untuk mengambil gambar utama
     // karena API list tidak menyediakannya.
     // Untuk sementara, kita biarkan null.
     return data.map((json) => Property.fromJson(json)).toList();
   } catch (e) {
     throw Exception('Gagal memuat properti: $e');
   }
 }

 Future<Property> getPropertyDetail(String id) async {
   try {
     final response = await _apiClient.get('/properties/$id');
     final propertyData = response['data']['property'];
     final images = response['data']['images'] as List;
     
     // Menambahkan gambar utama ke data properti
     if (images.isNotEmpty) {
       propertyData['gambar'] = images.first['gambar'];
     }
     
     return Property.fromJson(propertyData);
   } catch (e) {
     throw Exception('Gagal memuat detail properti: $e');
   }
 }
}