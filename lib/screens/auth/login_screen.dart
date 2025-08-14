// screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waisaka_property/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Masuk atau Daftar")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (Widget untuk form email & password Anda) ...

              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("ATAU"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // TOMBOL LOGIN GOOGLE
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Image.asset('assets/images/google_logo.png',
                          height: 24.0), // Pastikan Anda punya logo ini
                      label: const Text("Masuk dengan Google"),
                      onPressed: () async {
                        bool success = await authProvider.signInWithGoogle();
                        if (success && context.mounted) {
                          // Jika berhasil, kembali ke halaman sebelumnya atau ke home
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else if (context.mounted) {
                          // Tampilkan pesan error jika gagal
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Gagal masuk dengan Google.")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
