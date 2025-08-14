// lib/screens/search/search_result_screen.dart

import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/api_service.dart';
import '../../widgets/property_card.dart';

class SearchResultScreen extends StatefulWidget {
  final Map<String, dynamic> filters;

  const SearchResultScreen({super.key, required this.filters});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late Future<List<Property>> _searchFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _searchFuture = _apiService.searchProperties(widget.filters);
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.filters['location'] ?? 'Properti';

    return Scaffold(
      appBar: AppBar(
        title: Text("Hasil Pencarian: $location"),
      ),
      body: FutureBuilder<List<Property>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada properti yang cocok ditemukan."));
          }

          final properties = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              return PropertyCard(property: properties[index]);
            },
          );
        },
      ),
    );
  }
}
