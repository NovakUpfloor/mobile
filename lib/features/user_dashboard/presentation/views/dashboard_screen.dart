// Penjelasan:
// Halaman utama setelah user login (poin 6, 7, 8, 9).
// - Menggunakan BottomNavigationBar untuk navigasi antar fitur dasbor.
// - Menampilkan UI yang berbeda untuk 'User' dan 'Admin'.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waisaka_property/core/di/service_locator.dart';
import 'package:waisaka_property/features/auth/data/models/user.dart';
import 'package:waisaka_property/features/auth/presentation/bloc/auth_bloc.dart';

class DashboardScreen extends StatelessWidget {
 const DashboardScreen({super.key});

 @override
 Widget build(BuildContext context) {
   // Menyediakan AuthBloc yang sudah ada atau membuat yang baru jika belum ada
   return BlocProvider.value(
     value: sl<AuthBloc>()..add(FetchUserProfile()),
     child: const _DashboardView(),
   );
 }
}

class _DashboardView extends StatefulWidget {
 const _DashboardView();
 @override
 State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
 int _selectedIndex = 0;

 void _onItemTapped(int index) {
   setState(() => _selectedIndex = index);
 }

 @override
 Widget build(BuildContext context) {
   return BlocBuilder<AuthBloc, AuthState>(
     builder: (context, state) {
       if (state is UserProfileLoading || state is AuthInitial) {
         return const Scaffold(body: Center(child: CircularProgressIndicator()));
       }
       if (state is AuthFailure) {
         return Scaffold(body: Center(child: Text('Gagal memuat data: ${state.error}')));
       }
       if (state is UserProfileLoaded) {
         final user = state.user;
         final bool isAdmin = user.aksesLevel == 'Admin';

         final List<Widget> widgetOptions = [
           const Center(child: Text('Halaman Dashboard Statistik')),
           const Center(child: Text('Halaman Properti Saya')),
           _ProfileView(user: user),
           if (isAdmin) const Center(child: Text('Halaman Konfirmasi Admin')),
         ];

         final List<BottomNavigationBarItem> navItems = [
           const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
           const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Iklan Saya'),
           const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
           if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
         ];

         return BlocListener<AuthBloc, AuthState>(
           listener: (context, state) {
             if (state is AuthLogoutSuccess) {
               GoRouter.of(context).go('/');
             }
           },
           child: Scaffold(
             appBar: AppBar(
               title: const Text('Dasbor Saya'),
               actions: [
                 IconButton(
                   icon: const Icon(Icons.logout),
                   tooltip: 'Logout',
                   onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                 ),
               ],
             ),
             body: widgetOptions.elementAt(_selectedIndex),
             bottomNavigationBar: BottomNavigationBar(
               items: navItems,
               currentIndex: _selectedIndex,
               selectedItemColor: Colors.blue[800],
               unselectedItemColor: Colors.grey,
               onTap: _onItemTapped,
               showUnselectedLabels: true,
               type: BottomNavigationBarType.fixed,
             ),
           ),
         );
       }
       return const Scaffold(body: Center(child: Text('Terjadi kesalahan.')));
     },
   );
 }
}

// Widget untuk menampilkan profil di dalam dasbor
class _ProfileView extends StatelessWidget {
 final User user;
 const _ProfileView({required this.user});

 @override
 Widget build(BuildContext context) {
   return ListView(
     padding: const EdgeInsets.all(16),
     children: [
       ListTile(
         leading: const Icon(Icons.person),
         title: const Text('Nama'),
         subtitle: Text(user.name),
       ),
       ListTile(
         leading: const Icon(Icons.email),
         title: const Text('Email'),
         subtitle: Text(user.email),
       ),
       ListTile(
         leading: const Icon(Icons.credit_card),
         title: const Text('Sisa Kuota Iklan'),
         subtitle: Text('${user.sisaKuota} iklan'),
       ),
       const SizedBox(height: 20),
       ElevatedButton(
         onPressed: () {
           // Navigasi ke halaman pembelian paket
         },
         child: const Text('Beli Paket Iklan'),
       )
     ],
   );
 }
}