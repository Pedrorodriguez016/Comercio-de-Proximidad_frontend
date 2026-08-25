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
      final str = val.toString().trim();
      if (str.isEmpty) return DateTime.now();

      final iso = DateTime.tryParse(str);
      if (iso != null) return iso;

      try {
        final parts = str.split(' ');
        final dateParts = parts[0].split('/');
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);

          int hour = 0;
          int minute = 0;
          if (parts.length > 1) {
            final timeParts = parts[1].split(':');
            if (timeParts.length >= 2) {
              hour = int.parse(timeParts[0]);
              minute = int.parse(timeParts[1]);
            }
          }
          return DateTime(year, month, day, hour, minute);
        }
      } catch (e) {
        print("Date parse error for '$str': $e");
      }
      return DateTime.now();
    }

    String cId = (json['commerce_id'] ?? json['merchant_id'] ?? '').toString();
    String cName = (json['commerce_name'] ?? json['merchant_name'] ?? '').toString();

    if (json['commerce'] is Map<String, dynamic>) {
      final commMap = json['commerce'] as Map<String, dynamic>;
      if (cId.isEmpty && commMap['id'] != null) {
        cId = commMap['id'].toString();
      }
      if (cName.isEmpty && commMap['name'] != null) {
        cName = commMap['name'].toString();
      }
    }

    return PurchaseModel(
      id: (json['id'] ?? json['_id'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? json['user_email'] ?? '').toString(),
      commerceId: cId,
      commerceName: cName,
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
