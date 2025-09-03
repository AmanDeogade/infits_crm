class FilterUser {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FilterUser({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory FilterUser.fromJson(Map<String, dynamic> json) {
    return FilterUser(
      id: json['id']?.toInt(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'date': date?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  FilterUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FilterUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}




