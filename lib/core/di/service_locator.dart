// Penjelasan:
// File ini mengkonfigurasi Dependency Injection menggunakan GetIt.
// Tujuannya adalah untuk membuat instance dari class-class penting (seperti Repositories, BLoCs, ApiClient)
// dan membuatnya tersedia di seluruh aplikasi tanpa perlu passing constructor secara manual.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:waisaka_property/core/api/api_client.dart';
import 'package:waisaka_property/features/article/data/repositories/article_repository.dart';
import 'package:waisaka_property/features/auth/data/repositories/auth_repository.dart';
import 'package:waisaka_property/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waisaka_property/features/gemini/data/repositories/gemini_repository.dart';
import 'package:waisaka_property/features/gemini/presentation/bloc/gemini_bloc.dart';
import 'package:waisaka_property/features/home/presentation/bloc/home_bloc.dart';
import 'package:waisaka_property/features/property/data/repositories/property_repository.dart';
import 'package:waisaka_property/features/property/presentation/bloc/property_detail_bloc.dart';
import 'package:waisaka_property/features/user_dashboard/data/repositories/dashboard_repository.dart';

final sl = GetIt.instance; // sl = Service Locator

void setupServiceLocator() {
 // BLoCs / Cubits (dibuat instance baru setiap kali diminta)
 sl.registerFactory(() => HomeBloc(
       propertyRepository: sl(),
       articleRepository: sl(),
       geminiRepository: sl(),
     ));
 sl.registerFactory(() => PropertyDetailBloc(propertyRepository: sl()));
 sl.registerFactory(() => GeminiBloc(geminiRepository: sl()));
 sl.registerFactory(() => AuthBloc(authRepository: sl()));
 
 // Repositories (hanya dibuat satu kali dan digunakan kembali)
 sl.registerLazySingleton(() => PropertyRepository(apiClient: sl()));
 sl.registerLazySingleton(() => ArticleRepository(apiClient: sl()));
 sl.registerLazySingleton(() => GeminiRepository(apiClient: sl()));
 sl.registerLazySingleton(() => AuthRepository(
       apiClient: sl(),
       secureStorage: sl(),
     ));
 sl.registerLazySingleton(() => DashboardRepository(apiClient: sl()));

 // Core Services / External Packages
 sl.registerLazySingleton(() => ApiClient(secureStorage: sl()));
 sl.registerLazySingleton(() => const FlutterSecureStorage());
}