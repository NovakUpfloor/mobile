// Penjelasan:
// Model data untuk merepresentasikan satu objek Paket Iklan.

import 'package:equatable/equatable.dart';

class Package extends Equatable {
 final int id;
 final String name;
 final String price;
 final int adQuota;
 final String? description;

 const Package({
   required this.id,
   required this.name,
   required this.price,
   required this.adQuota,
   this.description,
 });

 factory Package.fromJson(Map<String, dynamic> json) {
   return Package(
     id: json['id'],
     name: json['nama_paket'],
     price: json['harga'],
     adQuota: json['kuota_iklan'],
     description: json['deskripsi'],
   );
 }

 @override
 List<Object?> get props => [id, name, price, adQuota, description];
}