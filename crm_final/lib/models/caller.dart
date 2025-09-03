class Caller {
  final int? id;
  final String name;
  final String? email;
  final int? totalCalls;
  final int? connectedCalls;
  final int? notConnectedCalls;
  final int? totalDurationMinutes;
  final double? durationRaisePercentage;
  final String? firstCallTime;
  final String? lastCallTime;
  final DateTime? createdAt;

  Caller({
    this.id,
    required this.name,
    this.email,
    this.totalCalls,
    this.connectedCalls,
    this.notConnectedCalls,
    this.totalDurationMinutes,
    this.durationRaisePercentage,
    this.firstCallTime,
    this.lastCallTime,
    this.createdAt,
  });

  factory Caller.fromJson(Map<String, dynamic> json) {
    String? parseTime(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      return str.isEmpty ? null : str;
    }
    return Caller(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String?,
      totalCalls: json['total_calls'] as int?,
      connectedCalls: json['connected_calls'] as int?,
      notConnectedCalls: json['not_connected_calls'] as int?,
      totalDurationMinutes: json['total_duration_minutes'] as int?,
      durationRaisePercentage: json['duration_raise_percentage'] is double
          ? json['duration_raise_percentage'] as double
          : double.tryParse(json['duration_raise_percentage']?.toString() ?? ''),
      firstCallTime: parseTime(json['first_call_time']),
      lastCallTime: parseTime(json['last_call_time']),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'total_calls': totalCalls,
      'connected_calls': connectedCalls,
      'not_connected_calls': notConnectedCalls,
      'total_duration_minutes': totalDurationMinutes,
      'duration_raise_percentage': durationRaisePercentage,
      'first_call_time': firstCallTime,
      'last_call_time': lastCallTime,
      'created_at': createdAt?.toIso8601String(),
    };
  }
} 