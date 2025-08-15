// Penjelasan:
// Ini adalah UI untuk halaman pendaftaran (poin 4 & 5).
// - Menampilkan pesan ajakan untuk mengiklankan properti.
// - Memiliki form untuk data diri.
// - Mengambil dan menampilkan daftar paket iklan dari API.
// - Pengguna wajib memilih paket sebelum mendaftar.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:waisaka_property/core/di/service_locator.dart';
import 'package:waisaka_property/features/auth/data/models/package_model.dart';
import 'package:waisaka_property/features/auth/presentation/bloc/auth_bloc.dart';

class RegisterScreen extends StatelessWidget {
 const RegisterScreen({super.key});

 @override
 Widget build(BuildContext context) {
   return BlocProvider(
     create: (context) => sl<AuthBloc>()..add(FetchPackages()),
     child: const _RegisterView(),
   );
 }
}

class _RegisterView extends StatefulWidget {
 const _RegisterView();
 @override
 State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
 final _formKey = GlobalKey<FormState>();
 final _nameController = TextEditingController();
 final _usernameController = TextEditingController();
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();
 int? _selectedPackageId;

 @override
 void dispose() {
   _nameController.dispose();
   _usernameController.dispose();
   _emailController.dispose();
   _passwordController.dispose();
   super.dispose();
 }

 void _register() {
   if (_formKey.currentState!.validate()) {
     if (_selectedPackageId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Silakan pilih paket iklan terlebih dahulu.')),
       );
       return;
     }
     context.read<AuthBloc>().add(AuthRegisterRequested(
           name: _nameController.text,
           username: _usernameController.text,
           email: _emailController.text,
           password: _passwordController.text,
           packageId: _selectedPackageId,
         ));
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: const Text('Buat Akun Baru')),
     body: BlocListener<AuthBloc, AuthState>(
       listener: (context, state) {
         if (state is AuthFailure) {
           ScaffoldMessenger.of(context)
             ..hideCurrentSnackBar()
             ..showSnackBar(SnackBar(content: Text('Registrasi Gagal: ${state.error}')));
         }
         if (state is AuthRegisterSuccess) {
           showDialog(
             context: context,
             barrierDismissible: false,
             builder: (ctx) => AlertDialog(
               title: const Text('Registrasi Berhasil'),
               content: const Text(
                   'Link verifikasi telah dikirim ke email Anda. Silakan periksa kotak masuk dan folder spam untuk melanjutkan.'),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.of(ctx).pop();
                     GoRouter.of(context).go('/login');
                   },
                   child: const Text('OK'),
                 ),
               ],
             ),
           );
         }
       },
       child: SingleChildScrollView(
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 const SizedBox(height: 20),
                 const Text(
                   'Apakah anda ingin mengiklankan property anda ke Waisaka Property? Silahkan sign up.',
                   textAlign: TextAlign.center,
                   style: TextStyle(fontSize: 16, color: Colors.black87),
                 ),
                 const SizedBox(height: 32),
                 _buildTextFormFields(),
                 const SizedBox(height: 24),
                 _buildPackageList(),
                 const SizedBox(height: 24),
                 BlocBuilder<AuthBloc, AuthState>(
                   builder: (context, state) {
                     if (state is AuthLoading) {
                       return const Center(child: CircularProgressIndicator());
                     }
                     return ElevatedButton(
                       onPressed: _register,
                       style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                       child: const Text('Daftar Sekarang'),
                     );
                   },
                 ),
                 const SizedBox(height: 16),
                 TextButton(
                   onPressed: () => GoRouter.of(context).go('/login'),
                   child: const Text('Sudah punya akun? Login'),
                 )
               ],
             ),
           ),
         ),
       ),
     ),
   );
 }

 Widget _buildTextFormFields() {
   return Column(
     children: [
       TextFormField(
         controller: _nameController,
         decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
         validator: (v) => v == null || v.isEmpty ? 'Nama lengkap tidak boleh kosong' : null,
       ),
       const SizedBox(height: 16),
       TextFormField(
         controller: _usernameController,
         decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
         validator: (v) => v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
       ),
       const SizedBox(height: 16),
       TextFormField(
         controller: _emailController,
         keyboardType: TextInputType.emailAddress,
         decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
         validator: (v) => v == null || !v.contains('@') ? 'Masukkan email yang valid' : null,
       ),
       const SizedBox(height: 16),
       TextFormField(
         controller: _passwordController,
         obscureText: true,
         decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
         validator: (v) => v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
       ),
     ],
   );
 }

 Widget _buildPackageList() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text('Pilih Paket Iklan:', style: Theme.of(context).textTheme.titleMedium),
       const SizedBox(height: 8),
       BlocBuilder<AuthBloc, AuthState>(
         buildWhen: (prev, curr) => curr is AuthPackagesLoading || curr is AuthPackagesLoadSuccess || curr is AuthFailure,
         builder: (context, state) {
           if (state is AuthPackagesLoading) {
             return const Center(child: CircularProgressIndicator());
           }
           if (state is AuthPackagesLoadSuccess) {
             return Container(
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.grey.shade400),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: ListView.separated(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: state.packages.length,
                 itemBuilder: (context, index) {
                   final package = state.packages[index];
                   final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                   return RadioListTile<int>(
                     title: Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Text('${package.adQuota} Iklan - ${currencyFormatter.format(double.tryParse(package.price) ?? 0)}'),
                     value: package.id,
                     groupValue: _selectedPackageId,
                     onChanged: (value) {
                       setState(() {
                         _selectedPackageId = value;
                       });
                     },
                   );
                 },
                 separatorBuilder: (context, index) => const Divider(height: 1),
               ),
             );
           }
           if (state is AuthFailure) {
             return Text('Gagal memuat paket: ${state.error}', style: const TextStyle(color: Colors.red));
           }
           return const Text('Silakan tunggu...');
         },
       ),
     ],
   );
 }
}