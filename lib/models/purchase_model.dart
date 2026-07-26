class PurchaseModel {
  String id;
  String email;
  String commerceId;
  String commerceName;
  double amount;
  DateTime date;
  double pointsEarned;

  PurchaseModel({
    required this.id,
    required this.email,
    required this.commerceId,
    this.commerceName = '',
    required this.amount,
    required this.date,
    this.pointsEarned = 0.0,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return PurchaseModel(
      id: (json['id'] ?? json['_id'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? json['user_email'] ?? '').toString(),
      commerceId: (json['commerce_id'] ?? json['merchant_id'] ?? '').toString(),
      commerceName: (json['commerce_name'] ?? json['merchant_name'] ?? '').toString(),
      amount: parseDouble(json['amount'] ?? json['total_amount'] ?? json['amount_total']),
      date: parseDate(json['date'] ?? json['date_order'] ?? json['create_date']),
      pointsEarned: parseDouble(json['points'] ?? json['earned_points'] ?? json['points_earned']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'commerce_id': commerceId,
      'commerce_name': commerceName,
      'amount': amount,
      'date': date.toIso8601String(),
      'points': pointsEarned,
    };
  }
}
