class Lead {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? altPhone;
  final String? addressLine;
  final String? city;
  final String? state;
  final String? country;
  final String? zip;
  final int? rating;
  final int campaignId;
  final String? currentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lead({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.altPhone,
    this.addressLine,
    this.city,
    this.state,
    this.country,
    this.zip,
    this.rating,
    required this.campaignId,
    this.currentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      altPhone: json['alt_phone'] as String?,
      addressLine: json['address_line'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      zip: json['zip'] as String?,
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse(json['rating']?.toString() ?? ''),
      campaignId: json['campaign_id'] is int
          ? json['campaign_id'] as int
          : int.tryParse(json['campaign_id']?.toString() ?? '') ?? 0,
      currentStatus: json['current_status'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'alt_phone': altPhone,
      'address_line': addressLine,
      'city': city,
      'state': state,
      'country': country,
      'zip': zip,
      'rating': rating,
      'campaign_id': campaignId,
      'current_status': currentStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 