// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Impor untuk Firebase ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini dibuat otomatis oleh FlutterFire

// --- Impor untuk Provider dan Halaman/Screen ---
import 'package:waisaka_property/providers/auth_provider.dart';
import 'package:waisaka_property/screens/home/home_screen.dart';
import 'package:waisaka_property/screens/profile/profile_screen.dart';
import 'package:waisaka_property/screens/auth/login_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Impor paket dotenv

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat file .env di sini
  await dotenv.load(fileName: ".env");

  // Proses inisialisasi Firebase menggunakan file firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Menjalankan aplikasi setelah Firebase siap
  runApp(
    // Menggunakan Provider untuk state management autentikasi
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const WaisakaPropertyApp(),
    ),
  );
}

class WaisakaPropertyApp extends StatelessWidget {
  const WaisakaPropertyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waisaka Property',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF1B5E20), // Warna hijau tua
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white, // Warna teks di AppBar
          elevation: 1,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Anda bisa menambahkan kustomisasi tema lainnya di sini
      ),

      // Halaman pertama yang akan ditampilkan adalah HomeScreen (tidak perlu login)
      home: const HomeScreen(),

      // Mendefinisikan rute/halaman yang bisa dinavigasi di dalam aplikasi
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        // Tambahkan rute lain jika ada di sini
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
