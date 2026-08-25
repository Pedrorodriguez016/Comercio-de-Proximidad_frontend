class UserModel {
  String id;
  String email;
  String name;
  String city;
  int? odooPartnerId;
  double points;
  bool firstLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.city = '',
    this.odooPartnerId,
    this.points = 0.0,
    this.firstLogin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int? parsePartnerId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    double parsePoints(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawId = (json['id'] ?? json['_id'] ?? json['keycloak_id'] ?? json['sub'] ?? '').toString();
    final validId = rawId.startsWith('did:') ? '' : rawId;

    return UserModel(
      id: validId,
      email: (json['email'] ?? json['preferred_username'] ?? '').toString(),
      name: (json['name'] ?? json['given_name'] ?? 'Usuari').toString(),
      city: (json['city'] ?? json['poblacion'] ?? '').toString(),
      odooPartnerId: parsePartnerId(
          json['odoo_partner_id'] ?? json['customer_id'] ?? json['odoo_id']),
      points: parsePoints(
          json['points'] ?? json['loyalty_points'] ?? json['balance']),
      firstLogin: json['firstLogin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'odoo_partner_id': odooPartnerId,
      'points': points,
      'firstLogin': firstLogin,
    };
  }
}
