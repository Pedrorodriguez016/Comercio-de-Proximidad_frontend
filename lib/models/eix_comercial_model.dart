class EixComercialModel {
  int id;
  String name;

  EixComercialModel({
    required this.id,
    required this.name,
  });

  factory EixComercialModel.fromJson(Map<String, dynamic> json) {
    return EixComercialModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
