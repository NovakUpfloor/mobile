// Penjelasan:
// Model data untuk merepresentasikan satu objek Artikel/Berita.

import 'package:equatable/equatable.dart';

class Article extends Equatable {
 final int id;
 final String title;
 final String slug;
 final String summary;
 final String? imageUrl;
 final String category;

 const Article({
   required this.id,
   required this.title,
   required this.slug,
   required this.summary,
   this.imageUrl,
   required this.category,
 });

 factory Article.fromJson(Map<String, dynamic> json) {
   final String baseUrl = "https://waisakaproperty.com"; // Sesuaikan dengan base URL gambar Anda
   return Article(
     id: json['id_berita'] ?? 0,
     title: json['judul_berita'] ?? 'Tanpa Judul',
     slug: json['slug_berita'] ?? '',
     summary: json['keywords'] ?? '',
     imageUrl: json['gambar'] != null ? '$baseUrl/assets/upload/image/${json['gambar']}' : null,
     category: json['nama_kategori'] ?? 'Umum',
   );
 }

 @override
 List<Object?> get props => [id, title, slug, summary, imageUrl, category];
}