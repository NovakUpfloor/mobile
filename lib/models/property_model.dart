// lib/models/property_model.dart

class Property {
  final int id;
  final String name;
  final String slug;
  final String type;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String? imageUrl;

  Property({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    this.imageUrl,
  });

  factory Property.fromJson(Map<String, dynamic> json, String? firstImage) {
    return Property(
      id: json['id_property'] ?? 0,
      name: json['nama_property'] ?? 'Nama Tidak Tersedia',
      slug: json['slug_property'] ?? '',
      type: json['tipe'] ?? 'jual',
      price: double.tryParse(json['harga'].toString()) ?? 0.0,
      location: "${json['nama_kabupaten'] ?? ''}, ${json['nama_provinsi'] ?? ''}",
      bedrooms: json['kamar_tidur'] ?? 0,
      bathrooms: json['kamar_mandi'] ?? 0,
      imageUrl: firstImage,
    );
  }
}
