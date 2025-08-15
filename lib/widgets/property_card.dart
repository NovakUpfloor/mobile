// Penjelasan:
// Widget untuk menampilkan satu kartu properti dalam daftar.
// Dibuat reusable agar bisa digunakan di halaman utama, hasil pencarian, dll.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:waisaka_property/features/property/data/models/property_model.dart';

class PropertyCard extends StatelessWidget {
 final Property property;

 const PropertyCard({super.key, required this.property});

 @override
 Widget build(BuildContext context) {
   final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
   final formattedPrice = currencyFormatter.format(property.price);

   return GestureDetector(
     onTap: () {
       context.go('/property/${property.id}');
     },
     child: Container(
       width: 220,
       margin: const EdgeInsets.all(8.0),
       child: Card(
         clipBehavior: Clip.antiAlias,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
         elevation: 4,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Stack(
               children: [
                 CachedNetworkImage(
                   imageUrl: property.imageUrl ?? '',
                   height: 150,
                   width: double.infinity,
                   fit: BoxFit.cover,
                   placeholder: (context, url) => Container(
                     height: 150,
                     color: Colors.grey[200],
                   ),
                   errorWidget: (context, url, error) => Container(
                     height: 150,
                     color: Colors.grey[200],
                     child: const Icon(Icons.house_outlined, color: Colors.grey, size: 50),
                   ),
                 ),
                 Positioned(
                   top: 8,
                   left: 8,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: Colors.black54,
                       borderRadius: BorderRadius.circular(5),
                     ),
                     child: Text(
                       property.type.toUpperCase(),
                       style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                     ),
                   ),
                 ),
               ],
             ),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     property.name,
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                   const SizedBox(height: 4),
                   Text(
                     property.location,
                     style: TextStyle(color: Colors.grey[600], fontSize: 12),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                   const SizedBox(height: 8),
                   Text(
                     formattedPrice,
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).primaryColor,
                       fontSize: 16,
                     ),
                   ),
                 ],
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }
}