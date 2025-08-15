// Penjelasan:
// Repository untuk fitur-fitur di dalam dasbor pengguna.

import 'package:waisaka_property/core/api/api_client.dart';

class DashboardRepository {
 final ApiClient _apiClient;

 DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

 // Tambahkan fungsi-fungsi untuk dasbor di sini
 // Contoh:
 // Future<List<Property>> getMyProperties() async { ... }
 // Future<void> purchasePackage(int packageId, File proof) async { ... }
}