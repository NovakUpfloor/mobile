// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waisaka_property/providers/auth_provider.dart';
import 'package:waisaka_property/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil status autentikasi dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // Jika pengguna tidak login, tampilkan halaman untuk login
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Jika pengguna sudah login, tampilkan halaman profil
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Menampilkan foto profil pengguna (jika ada)
              CircleAvatar(
                radius: 50,
                backgroundImage: authProvider.user?.photoURL != null
                    ? NetworkImage(authProvider.user!.photoURL!)
                    : null,
                child: authProvider.user?.photoURL == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),

              // Menampilkan nama pengguna
              Text(
                authProvider.user?.displayName ?? 'Nama Pengguna',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Menampilkan email pengguna
              Text(
                authProvider.user?.email ?? 'email@example.com',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Tombol Logout
              ElevatedButton(
                onPressed: () {
                  // Memanggil fungsi signOut dari AuthProvider
                  context.read<AuthProvider>().signOut();

                  // Mengarahkan pengguna kembali ke halaman utama setelah logout
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
