// Penjelasan:
// Model data untuk menangani respons terstruktur dari backend setelah
// backend berkomunikasi dengan API Gemini.

class GeminiActionResponse {
 final String action;
 final Map<String, dynamic> data;

 GeminiActionResponse({required this.action, required this.data});

 factory GeminiActionResponse.fromJson(Map<String, dynamic> json) {
   return GeminiActionResponse(
     action: json['action'] ?? 'show_message',
     data: json,
   );
 }
}