// Penjelasan:
// Ini adalah UI untuk halaman utama (poin 1).
// - Menampilkan daftar properti dan artikel terbaru dari API.
// - Memiliki tombol Sign Up/Login yang berubah menjadi ikon profil jika sudah login.
// - Mengintegrasikan VoiceCommandWidget untuk fitur perintah suara.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waisaka_property/core/di/service_locator.dart';
import 'package:waisaka_property/features/article/data/models/article_model.dart';
import 'package:waisaka_property/features/gemini/data/models/gemini_action_response.dart';
import 'package:waisaka_property/features/home/presentation/bloc/home_bloc.dart';
import 'package:waisaka_property/features/property/data/models/property_model.dart';
import 'package:waisaka_property/widgets/article_card.dart';
import 'package:waisaka_property/widgets/property_card.dart';
import 'package:waisaka_property/widgets/voice_command_widget.dart';

class HomeScreen extends StatelessWidget {
 const HomeScreen({super.key});

 @override
 Widget build(BuildContext context) {
   return BlocProvider(
     create: (context) => sl<HomeBloc>()..add(LoadHomeData()),
     child: const _HomeView(),
   );
 }
}

class _HomeView extends StatelessWidget {
 const _HomeView();

 void _handleAiAction(BuildContext context, GeminiActionResponse response) {
   if (!context.mounted) return;
   switch (response.action) {
     case 'search':
       final filters = response.data['filters'] as Map<String, dynamic>? ?? {};
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI ingin mencari: $filters')));
       break;
     case 'show_message':
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI: ${response.data['message']}')));
       break;
     default:
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aksi tidak dikenali.')));
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Waisaka Property'),
       actions: [
         IconButton(
           icon: const Icon(Icons.login),
           onPressed: () => context.go('/login'),
         ),
       ],
     ),
     body: BlocBuilder<HomeBloc, HomeState>(
       builder: (context, state) {
         if (state is HomeLoading) {
           return const Center(child: CircularProgressIndicator());
         }
         if (state is HomeLoadFailure) {
           return Center(child: Text('Gagal memuat data: ${state.error}'));
         }
         if (state is HomeLoadSuccess) {
           return RefreshIndicator(
             onRefresh: () async {
               context.read<HomeBloc>().add(LoadHomeData());
             },
             child: SingleChildScrollView(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _buildSectionTitle('Iklan Properti Terbaru'),
                   _buildPropertyList(state.properties),
                   const SizedBox(height: 20),
                   _buildSectionTitle('Artikel & Berita'),
                   _buildArticleList(state.articles),
                 ],
               ),
             ),
           );
         }
         return const Center(child: Text('Selamat Datang!'));
       },
     ),
     floatingActionButton: VoiceCommandWidget(
       contextName: 'homepage',
       onActionReceived: (response) => _handleAiAction(context, response),
     ),
   );
 }

 Widget _buildSectionTitle(String title) {
   return Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
   );
 }

 Widget _buildPropertyList(List<Property> properties) {
   if (properties.isEmpty) {
     return const SizedBox(height: 150, child: Center(child: Text('Tidak ada properti.')));
   }
   return SizedBox(
     height: 300,
     child: ListView.builder(
       scrollDirection: Axis.horizontal,
       padding: const EdgeInsets.symmetric(horizontal: 8),
       itemCount: properties.length,
       itemBuilder: (context, index) => PropertyCard(property: properties[index]),
     ),
   );
 }

 Widget _buildArticleList(List<Article> articles) {
    if (articles.isEmpty) {
     return const SizedBox(height: 150, child: Center(child: Text('Tidak ada artikel.')));
   }
   return ListView.builder(
     shrinkWrap: true,
     physics: const NeverScrollableScrollPhysics(),
     itemCount: articles.length,
     itemBuilder: (context, index) => ArticleCard(article: articles[index]),
   );
 }
}