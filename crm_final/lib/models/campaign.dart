class Campaign {
  final int? id;
  final String name;
  final String? description;
  final int createdBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final double progressPct;
  final String status;
  final int totalLeads;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Campaign({
    this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.startDate,
    this.endDate,
    this.progressPct = 0.0,
    this.status = 'DRAFT',
    this.totalLeads = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as int,
      startDate:
          json['start_date'] != null
              ? DateTime.parse(json['start_date'])
              : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      progressPct:
          json['progress_pct'] == null
              ? 0.0
              : (json['progress_pct'] is num)
              ? (json['progress_pct'] as num).toDouble()
              : double.tryParse(json['progress_pct'].toString()) ?? 0.0,
      status: json['status'] as String? ?? 'DRAFT',
      totalLeads: json['total_leads'] as int? ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'progress_pct': progressPct,
      'status': status,
      'total_leads': totalLeads,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
