// providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http; // Jika perlu sinkronisasi ke backend Anda
// import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;

  // Tambahkan field berikut jika belum ada
  bool _isAuthenticated = false;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Getter untuk isAuthenticated
  bool get isAuthenticated => _isAuthenticated;

  // Getter untuk token
  String? get token => _token;

  // Method tryAutoLogin
  Future<void> tryAutoLogin() async {
    // Contoh implementasi auto login sederhana
    // Ganti dengan logika sesuai kebutuhan aplikasi Anda
    // Misal: cek token di SharedPreferences
    // Jika ditemukan, set _isAuthenticated = true dan notifyListeners()
    // Jika tidak, set _isAuthenticated = false
    _isAuthenticated = false;
    notifyListeners();
  }

  // ... (fungsi login/register email password Anda yang sudah ada) ...

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Memulai proses login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Pengguna membatalkan login
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Mendapatkan detail autentikasi dari request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Membuat kredensial untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Login ke Firebase dengan kredensial
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // -- Opsional tapi SANGAT DISARANKAN --
      // 5. Sinkronisasi dengan Backend Laravel Anda
      // Kirim token Firebase (_user.getIdToken()) ke backend Anda.
      // Backend memverifikasi token ini, lalu membuat user baru di database Anda
      // atau mengambil data user yang sudah ada berdasarkan email.
      // await syncUserToBackend(_user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error saat login dengan Google: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
