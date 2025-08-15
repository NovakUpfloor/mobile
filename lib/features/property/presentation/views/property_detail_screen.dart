// Penjelasan:
// UI untuk halaman detail properti (poin 2).
// - Menampilkan semua informasi detail properti.
// - Memiliki tombol Hubungi dan Share.
// - Mengintegrasikan VoiceCommandWidget untuk perintah suara spesifik halaman ini.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waisaka_property/core/di/service_locator.dart';
import 'package:waisaka_property/features/gemini/data/models/gemini_action_response.dart';
import 'package:waisaka_property/features/property/presentation/bloc/property_detail_bloc.dart';
import 'package:waisaka_property/widgets/voice_command_widget.dart';

class PropertyDetailScreen extends StatelessWidget {
 final String propertyId;
 const PropertyDetailScreen({super.key, required this.propertyId});

 @override
 Widget build(BuildContext context) {
   return BlocProvider(
     create: (context) => sl<PropertyDetailBloc>()..add(FetchPropertyDetail(id: propertyId)),
     child: const _PropertyDetailView(),
   );
 }
}

class _PropertyDetailView extends StatelessWidget {
 const _PropertyDetailView();

 void _handleAiAction(BuildContext context, GeminiActionResponse response) {
   // Implementasi logika untuk menghubungi marketing, share, dll.
   // Contoh:
   if (response.action == 'contact_agent') {
     // Ambil nomor telepon dari data properti dan panggil fungsi _launchWhatsApp
   }
 }

 Future<void> _launchURL(String url) async {
   if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
     throw 'Could not launch $url';
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: const Text('Detail Properti')),
     body: BlocBuilder<PropertyDetailBloc, PropertyDetailState>(
       builder: (context, state) {
         if (state is PropertyDetailLoading) {
           return const Center(child: CircularProgressIndicator());
         }
         if (state is PropertyDetailLoadFailure) {
           return Center(child: Text('Gagal memuat data: ${state.error}'));
         }
         if (state is PropertyDetailLoadSuccess) {
           final property = state.property;
           final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

           return SingleChildScrollView(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Image.network(
                   property.imageUrl ?? 'https://placehold.co/600x400/EFEFEF/AAAAAA&text=Waisaka',
                   width: double.infinity,
                   height: 250,
                   fit: BoxFit.cover,
                 ),
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(property.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       Text(property.location, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                       const SizedBox(height: 16),
                       Text(currencyFormatter.format(property.price),
                           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                       const Divider(height: 32),
                       const Text('Spesifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           _buildSpecItem(Icons.bed, '${property.bedrooms} KT'),
                           _buildSpecItem(Icons.bathtub, '${property.bathrooms} KM'),
                         ],
                       ),
                       const Divider(height: 32),
                       Row(
                         children: [
                           Expanded(
                             child: ElevatedButton.icon(
                               icon: const Icon(Icons.phone),
                               label: const Text('Hubungi'),
                               onPressed: () { /* Logika telepon */ },
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: ElevatedButton.icon(
                               icon: const Icon(Icons.share),
                               label: const Text('Share'),
                               onPressed: () {
                                 Share.share('Lihat properti menarik ini: ${GoRouterState.of(context).uri}');
                               },
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                             ),
                           ),
                         ],
                       )
                     ],
                   ),
                 )
               ],
             ),
           );
         }
         return const SizedBox.shrink();
       },
     ),
     floatingActionButton: VoiceCommandWidget(
       contextName: 'detail_iklan',
       onActionReceived: (response) => _handleAiAction(context, response),
       additionalData: { 'property_id': context.read<PropertyDetailBloc>().state is PropertyDetailLoadSuccess ? (context.read<PropertyDetailBloc>().state as PropertyDetailLoadSuccess).property.id : 0 },
     ),
   );
 }

 Widget _buildSpecItem(IconData icon, String label) {
   return Column(
     children: [
       Icon(icon, size: 30, color: Colors.blue[800]),
       const SizedBox(height: 4),
       Text(label),
     ],
   );
 }
}