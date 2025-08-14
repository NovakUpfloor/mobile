// screens/property/property_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/constants.dart';
import '../../models/property/property_detail_model.dart';
import '../../services/api_service.dart';
import '../../services/gemini_service.dart';
import '../../widgets/voice_command_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  final String propertyName;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Future<PropertyDetail> _detailFuture;
  final ApiService _apiService = ApiService();
  PropertyDetail? _propertyDetail;

  @override
  void initState() {
    super.initState();
    _detailFuture = _apiService.fetchPropertyDetails(widget.propertyId);
  }

  void _handleAiAction(GeminiActionResponse response) {
    if (_propertyDetail == null) return;
    final agent = _propertyDetail!.agent;
    final propertyUrl =
        "https://waisakaproperty.com/properti/${_propertyDetail!.id}/${_propertyDetail!.name.replaceAll(' ', '-')}";
    switch (response.action) {
      case 'contact_agent':
        _launchWhatsApp(
          agent.phone,
          "Halo, saya tertarik dengan properti: $propertyUrl",
        );
        break;
      case 'share_whatsapp':
        SharePlus.instance.share(
          ShareParams(
              text:
                  "Lihat properti menarik ini di Waisaka Property! $propertyUrl"),
        );
        break;
      case 'share_facebook':
        final facebookUrl =
            "https://www.facebook.com/sharer/sharer.php?u=$propertyUrl";
        _launchURL(facebookUrl);
        break;
      case 'show_message':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI: ${response.data['message']}')),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aksi tidak dikenali.')));
    }
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tidak bisa membuka link: $url')));
    }
  }

  Future<void> _launchWhatsApp(String phone, String message) async {
    final Uri url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa membuka WhatsApp.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propertyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<PropertyDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error memuat detail: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Detail properti tidak ditemukan."),
            );
          }
          _propertyDetail = snapshot.data!;
          return _buildDetailContent(context, _propertyDetail!);
        },
      ),
      floatingActionButton: VoiceCommandWidget(
        context: 'detail_iklan',
        additionalData: {'property_id': widget.propertyId},
        onActionReceived: _handleAiAction,
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, PropertyDetail detail) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedPrice = currencyFormatter.format(detail.price);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(detail.images),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail.location,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Text(
                  formattedPrice,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(height: 32),
                Text(
                  "Spesifikasi",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildSpecificationGrid(detail),
                const Divider(height: 32),
                Text(
                  "Deskripsi",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  detail.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const Divider(height: 32),
                _buildAgentCard(context, detail.agent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<PropertyImage> images) {
    if (images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: '${imageBaseUrl}property/${images[index].imageUrl}',
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      ),
    );
  }

  Widget _buildSpecificationGrid(PropertyDetail detail) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4,
      children: [
        _specItem(Icons.bed_outlined, "Kamar Tidur", "${detail.bedrooms}"),
        _specItem(Icons.bathtub_outlined, "Kamar Mandi", "${detail.bathrooms}"),
        _specItem(
          Icons.square_foot_outlined,
          "Luas Tanah",
          "${detail.landArea} m²",
        ),
        _specItem(
          Icons.home_work_outlined,
          "Luas Bangunan",
          "${detail.buildingArea} m²",
        ),
      ],
    );
  }

  Widget _specItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildAgentCard(BuildContext context, Agent agent) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: agent.imageUrl != null
                      ? CachedNetworkImageProvider(
                          '${imageBaseUrl}staff/thumbs/${agent.imageUrl!}',
                        )
                      : null,
                  child: agent.imageUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hubungi Agen",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        agent.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call_outlined),
                    label: const Text("Telepon"),
                    onPressed: () => _launchURL('tel:${agent.phone}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text("WhatsApp"),
                    onPressed: () => _launchWhatsApp(
                      agent.phone,
                      "Halo, saya tertarik dengan properti ini.",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
