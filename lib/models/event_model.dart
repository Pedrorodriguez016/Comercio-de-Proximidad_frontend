
class EventModel {
  final int id;
  final String name;
  final String description;
  final String? dateBegin;
  final String? dateEnd;
  final int? seatsAvailable;
  final int? seatsMax;
  final String address;
  final String organizer;
  final bool isRegistered;
  final bool credentialIssued;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    this.dateBegin,
    this.dateEnd,
    this.seatsAvailable,
    this.seatsMax,
    required this.address,
    required this.organizer,
    this.isRegistered = false,
    this.credentialIssued = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dateBegin: json['date_begin'],
      dateEnd: json['date_end'],
      seatsAvailable: json['seats_available'] is int
          ? json['seats_available']
          : int.tryParse(json['seats_available']?.toString() ?? ''),
      seatsMax: json['seats_max'] is int
          ? json['seats_max']
          : int.tryParse(json['seats_max']?.toString() ?? ''),
      address: json['address'] ?? 'Barcelona',
      organizer: json['organizer'] ?? 'Comerç Associat',
      isRegistered: json['is_registered'] ?? false,
      credentialIssued: json['credential_issued'] ?? false,
    );
  }

  EventModel copyWith({bool? isRegistered, bool? credentialIssued}) {
    return EventModel(
      id: id,
      name: name,
      description: description,
      dateBegin: dateBegin,
      dateEnd: dateEnd,
      seatsAvailable: seatsAvailable,
      seatsMax: seatsMax,
      address: address,
      organizer: organizer,
      isRegistered: isRegistered ?? this.isRegistered,
      credentialIssued: credentialIssued ?? this.credentialIssued,
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final formatted = raw.trim().replaceAll(' ', 'T');
    final iso = (formatted.contains('Z') || formatted.contains('+'))
        ? formatted
        : '${formatted}Z';
    return DateTime.tryParse(iso)?.toLocal() ??
        DateTime.tryParse(formatted)?.toLocal();
  }

  DateTime? get parsedDateBegin => _parseDate(dateBegin);

  DateTime? get parsedDateEnd => _parseDate(dateEnd);
}
