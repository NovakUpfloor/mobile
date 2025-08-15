// Penjelasan:
// Model data untuk merepresentasikan objek Pengguna (User) setelah login.

import 'package:equatable/equatable.dart';

class User extends Equatable {
 final int idUser;
 final int? idStaff;
 final String name;
 final String username;
 final String email;
 final String aksesLevel;
 final int sisaKuota;

 const User({
   required this.idUser,
   this.idStaff,
   required this.name,
   required this.username,
   required this.email,
   required this.aksesLevel,
   required this.sisaKuota,
 });

 factory User.fromJson(Map<String, dynamic> json) {
   return User(
     idUser: json['id_user'],
     idStaff: json['id_staff'],
     name: json['nama'],
     username: json['username'],
     email: json['email'],
     aksesLevel: json['akses_level'],
     sisaKuota: json['sisa_kuota'] ?? 0,
   );
 }

 @override
 List<Object?> get props => [idUser, idStaff, name, username, email, aksesLevel, sisaKuota];
}