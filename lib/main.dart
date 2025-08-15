// Penjelasan:
// File ini adalah titik masuk utama aplikasi (entry point).
// Fungsinya:
// 1. Menginisialisasi semua service penting sebelum aplikasi berjalan,
//    seperti Service Locator (GetIt) dan memuat file .env.
// 2. Menjalankan aplikasi Flutter dengan widget root `MyApp`.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waisaka_property/app/app.dart';
import 'package:waisaka_property/core/di/service_locator.dart';

void main() async {
 // Memastikan semua binding Flutter siap.
 WidgetsFlutterBinding.ensureInitialized();
 // Memuat environment variables dari file .env.
 await dotenv.load(fileName: ".env");
 // Menginisialisasi semua dependensi (repositories, BLoCs, dll).
 setupServiceLocator();
 // Menjalankan aplikasi.
 runApp(const MyApp());
}