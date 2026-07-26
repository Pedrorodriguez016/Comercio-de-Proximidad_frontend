class CommerceModel {
  String id;
  String name;
  String category;
  String address;
  String neighborhood;
  String district;
  double? latitude;
  double? longitude;
  int? eixComercialId;
  String? eixComercialName;
  String? phone;
  String? email;
  String? description;

  CommerceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    this.neighborhood = '',
    this.district = '',
    this.latitude,
    this.longitude,
    this.eixComercialId,
    this.eixComercialName,
    this.phone,
    this.email,
    this.description,
  });

  factory CommerceModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    return CommerceModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Comerç sense nom').toString(),
      category: (json['type'] ?? json['category'] ?? 'General').toString(),
      address: (json['address'] ?? json['street'] ?? 'Adreça no disponible').toString(),
      neighborhood: (json['neighborhood'] ?? json['barri'] ?? '').toString(),
      district: (json['district'] ?? json['districte'] ?? '').toString(),
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      eixComercialId: parseInt(json['eix_comercial_id']),
      eixComercialName: json['eix_comercial_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': category,
      'address': address,
      'neighborhood': neighborhood,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'eix_comercial_id': eixComercialId,
      'eix_comercial_name': eixComercialName,
      'phone': phone,
      'email': email,
      'description': description,
    };
  }
}
