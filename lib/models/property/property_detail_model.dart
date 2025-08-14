// lib/models/property/property_detail_model.dart

class PropertyImage {
  final int id;
  final String imageUrl;
  PropertyImage({required this.id, required this.imageUrl});
  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(id: json['id_property_img'] ?? 0, imageUrl: json['gambar'] ?? '');
  }
}

class Agent {
  final int id;
  final String name;
  final String phone;
  final String? imageUrl;
  Agent({required this.id, required this.name, required this.phone, this.imageUrl});
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id_staff'] ?? 0,
      name: json['nama_staff'] ?? 'N/A',
      phone: json['telepon'] ?? '',
      imageUrl: json['gambar'],
    );
  }
}

class PropertyDetail {
  final int id;
  final String name;
  final String type;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final int landArea;
  final int buildingArea;
  final String description;
  final List<PropertyImage> images;
  final Agent agent;

  PropertyDetail({
    required this.id, required this.name, required this.type, required this.price,
    required this.location, required this.bedrooms, required this.bathrooms,
    required this.landArea, required this.buildingArea, required this.description,
    required this.images, required this.agent,
  });

  factory PropertyDetail.fromJson(Map<String, dynamic> json) {
    var propertyData = json['property'] ?? {};
    var imagesData = json['images'] as List? ?? [];
    var agentData = json['agent'] ?? {};

    List<PropertyImage> parsedImages = imagesData.map((i) => PropertyImage.fromJson(i)).toList();

    return PropertyDetail(
      id: propertyData['id_property'] ?? 0,
      name: propertyData['nama_property'] ?? 'N/A',
      type: propertyData['tipe'] ?? 'jual',
      price: double.tryParse(propertyData['harga'].toString()) ?? 0.0,
      location: "${propertyData['nama_kabupaten'] ?? ''}, ${propertyData['nama_provinsi'] ?? ''}",
      bedrooms: propertyData['kamar_tidur'] ?? 0,
      bathrooms: propertyData['kamar_mandi'] ?? 0,
      landArea: propertyData['lt'] ?? 0,
      buildingArea: propertyData['lb'] ?? 0,
      description: propertyData['isi'] ?? 'Tidak ada deskripsi.',
      images: parsedImages,
      agent: Agent.fromJson(agentData),
    );
  }
}
