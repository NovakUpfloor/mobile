// Penjelasan:
// Repository ini bertanggung jawab untuk mengambil data artikel dari API.

import 'package:waisaka_property/core/api/api_client.dart';
import 'package:waisaka_property/features/article/data/models/article_model.dart';

class ArticleRepository {
 final ApiClient _apiClient;

 ArticleRepository({required ApiClient apiClient}) : _apiClient = apiClient;

 Future<List<Article>> getArticles() async {
   try {
     final response = await _apiClient.get('/articles');
     final data = response['data']['data'] as List;
     return data.map((articleJson) => Article.fromJson(articleJson)).toList();
   } catch (e) {
     throw Exception('Gagal memuat artikel: $e');
   }
 }
}