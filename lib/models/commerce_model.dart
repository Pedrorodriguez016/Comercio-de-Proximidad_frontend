class CommerceModel {
  String id;
  String name;
  String category;
  String address;
  String zip;
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
    this.zip = '',
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

    int? eixId = parseInt(json['eix_comercial_id']);
    String? eixName = json['eix_comercial_name']?.toString();
    String dist = (json['district'] ?? json['districte'] ?? '').toString();
    String street = (json['address'] ?? json['street'] ?? '').toString();
    String city = (json['city'] ?? '').toString();
    String zipCode = (json['zip'] ?? '').toString();

    if (json['eix_comercial'] is Map<String, dynamic>) {
      final eixMap = json['eix_comercial'] as Map<String, dynamic>;
      eixId ??= parseInt(eixMap['id']);
      eixName ??= eixMap['name']?.toString();
      if (dist.isEmpty && eixMap['district'] != null) {
        dist = eixMap['district'].toString();
      }
    }

    String fullAddress = street;
    if (zipCode.isNotEmpty && !fullAddress.contains(zipCode)) {
      fullAddress = fullAddress.isNotEmpty ? "$fullAddress, $zipCode" : zipCode;
    }
    if (city.isNotEmpty && !fullAddress.toLowerCase().contains(city.toLowerCase())) {
      fullAddress = fullAddress.isNotEmpty ? "$fullAddress, $city" : city;
    }
    if (fullAddress.isEmpty) {
      fullAddress = 'Adreça no disponible';
    }

    String catName = 'General';
    if (json['type'] != null) {
      catName = json['type'].toString();
    } else if (json['category'] != null) {
      catName = json['category'].toString();
    } else if (json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      final firstCat = (json['categories'] as List).first;
      if (firstCat is Map && firstCat['name'] != null) {
        catName = firstCat['name'].toString();
      }
    }

    return CommerceModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Comerç sense nom').toString(),
      category: catName,
      address: fullAddress,
      zip: zipCode,
      neighborhood: (json['neighborhood'] ?? json['barri'] ?? '').toString(),
      district: dist,
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      eixComercialId: eixId,
      eixComercialName: eixName,
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
      'zip': zip,
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
