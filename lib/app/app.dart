// Penjelasan:
// File ini berisi widget root dari aplikasi, yaitu `MyApp`.
// Fungsinya:
// 1. Mengkonfigurasi `MaterialApp` yang akan membungkus seluruh aplikasi.
// 2. Mengatur tema global (warna, font, dll).
// 3. Mengintegrasikan sistem navigasi menggunakan `GoRouter`.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waisaka_property/core/di/service_locator.dart';
import 'package:waisaka_property/features/auth/data/repositories/auth_repository.dart';
import 'package:waisaka_property/features/auth/presentation/views/login_screen.dart';
import 'package:waisaka_property/features/auth/presentation/views/register_screen.dart';
import 'package:waisaka_property/features/home/presentation/views/home_screen.dart';
import 'package:waisaka_property/features/property/presentation/views/property_detail_screen.dart';
import 'package:waisaka_property/features/user_dashboard/presentation/views/dashboard_screen.dart';

class MyApp extends StatelessWidget {
 const MyApp({super.key});

 @override
 Widget build(BuildContext context) {
   return MaterialApp.router(
     routerConfig: _router,
     title: 'Waisaka Property',
     debugShowCheckedModeBanner: false,
     theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
       useMaterial3: true,
       scaffoldBackgroundColor: Colors.grey[100],
       appBarTheme: const AppBarTheme(
         backgroundColor: Color(0xFF0D47A1),
         foregroundColor: Colors.white,
         elevation: 2,
       ),
     ),
   );
 }
}

// Konfigurasi GoRouter untuk navigasi
final GoRouter _router = GoRouter(
 initialLocation: '/',
 // Logika redirect: Mengarahkan user jika belum/sudah login
 redirect: (BuildContext context, GoRouterState state) async {
   final authRepository = sl<AuthRepository>();
   final token = await authRepository.getToken();
   
   final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
   final isPublic = state.matchedLocation == '/' || state.matchedLocation.startsWith('/property') || state.matchedLocation.startsWith('/article');

   // Jika belum login dan mencoba akses halaman privat, redirect ke login
   if (token == null && !loggingIn && !isPublic) {
     return '/login';
   }

   // Jika sudah login dan mencoba akses halaman login/register, redirect ke dashboard
   if (token != null && loggingIn) {
     return '/dashboard';
   }

   return null;
 },
 routes: [
   GoRoute(
     path: '/',
     builder: (context, state) => const HomeScreen(),
   ),
   GoRoute(
     path: '/login',
     builder: (context, state) => const LoginScreen(),
   ),
   GoRoute(
     path: '/register',
     builder: (context, state) => const RegisterScreen(),
   ),
   GoRoute(
     path: '/property/:id',
     builder: (context, state) {
       final id = state.pathParameters['id']!;
       return PropertyDetailScreen(propertyId: id);
     },
   ),
   GoRoute(
     path: '/dashboard',
     builder: (context, state) => const DashboardScreen(),
   ),
 ],
);