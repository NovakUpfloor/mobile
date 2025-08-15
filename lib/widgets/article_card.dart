// Penjelasan:
// Widget untuk menampilkan satu kartu artikel dalam daftar.
// Dibuat reusable agar bisa digunakan di berbagai halaman.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waisaka_property/features/article/data/models/article_model.dart';

class ArticleCard extends StatelessWidget {
 final Article article;
 const ArticleCard({super.key, required this.article});

 @override
 Widget build(BuildContext context) {
   return Card(
     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
     clipBehavior: Clip.antiAlias,
     child: ListTile(
       leading: CachedNetworkImage(
         imageUrl: article.imageUrl ?? '',
         width: 80,
         height: 80,
         fit: BoxFit.cover,
         placeholder: (context, url) => Container(
           width: 80,
           height: 80,
           color: Colors.grey[200],
         ),
         errorWidget: (context, url, error) => Container(
           width: 80,
           height: 80,
           color: Colors.grey[200],
           child: const Icon(Icons.article_outlined, color: Colors.grey),
         ),
       ),
       title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
       subtitle: Text(article.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
       onTap: () {
         // Navigasi ke halaman detail artikel
       },
     ),
   );
 }
}