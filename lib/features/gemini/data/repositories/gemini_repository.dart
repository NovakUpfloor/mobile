// Penjelasan:
// Repository untuk fitur Gemini. Bertanggung jawab mengirimkan
// perintah teks ke backend untuk diproses oleh AI.

import 'package:waisaka_property/core/api/api_client.dart';
import 'package:waisaka_property/features/gemini/data/models/gemini_action_response.dart';

class GeminiRepository {
 final ApiClient _apiClient;

 GeminiRepository({required ApiClient apiClient}) : _apiClient = apiClient;
 
 Future<GeminiActionResponse> processCommand({
   required String text,
   required String context,
   Map<String, dynamic>? data,
 }) async {
   try {
     final response = await _apiClient.post(
       '/gemini-command',
       body: {
         'text': text,
         'context': context,
         'data': data ?? {},
       },
     );
     return GeminiActionResponse.fromJson(response);
   } catch (e) {
     // Mengembalikan pesan error dalam format GeminiActionResponse
     return GeminiActionResponse(
       action: 'show_message',
       data: {'message': e.toString().replaceAll('Exception: ', '')},
     );
   }
 }
}