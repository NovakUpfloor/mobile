// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/api_service.dart';
import '../../services/gemini_service.dart';
import '../../widgets/property_card.dart';
import '../../widgets/voice_command_widget.dart';
import '../search/search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Property>> _propertiesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _apiService.fetchProperties();
  }

  void _refreshProperties() => setState(() => _propertiesFuture = _apiService.fetchProperties());

  void _handleAiAction(GeminiActionResponse response) {
    switch (response.action) {
      case 'search':
        final filters = response.data['filters'] as Map<String, dynamic>? ?? {};
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchResultScreen(filters: filters)));
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
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshProperties, tooltip: 'Muat Ulang Data')],
      ),
      body: FutureBuilder<List<Property>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Gagal memuat data.\nError: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(onPressed: _refreshProperties, icon: const Icon(Icons.refresh), label: const Text('Coba Lagi'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))
                ]),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada properti yang tersedia.'));
          final properties = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: properties.length,
            itemBuilder: (context, index) => PropertyCard(property: properties[index]),
          );
        },
      ),
      floatingActionButton: VoiceCommandWidget(context: 'homepage', onActionReceived: _handleAiAction),
    );
  }
}
