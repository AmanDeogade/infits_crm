class CallMetrics {
  final int? id;
  final int userId;
  final int totalCalls;
  final int incomingCalls;
  final int outgoingCalls;
  final int missedCalls;
  final int connectedCalls;
  final int attemptedCalls;
  final int totalDurationSeconds;
  final int stageFresh;
  final int stageInterested;
  final int stageCommitted;
  final int stageNotInterested;

  CallMetrics({
    this.id,
    required this.userId,
    required this.totalCalls,
    required this.incomingCalls,
    required this.outgoingCalls,
    required this.missedCalls,
    required this.connectedCalls,
    required this.attemptedCalls,
    required this.totalDurationSeconds,
    required this.stageFresh,
    required this.stageInterested,
    required this.stageCommitted,
    required this.stageNotInterested,
  });

  factory CallMetrics.fromJson(Map<String, dynamic> json) {
    return CallMetrics(
      id: json['id'],
      userId: json['user_id'],
      totalCalls: json['total_calls'] ?? 0,
      incomingCalls: json['incoming_calls'] ?? 0,
      outgoingCalls: json['outgoing_calls'] ?? 0,
      missedCalls: json['missed_calls'] ?? 0,
      connectedCalls: json['connected_calls'] ?? 0,
      attemptedCalls: json['attempted_calls'] ?? 0,
      totalDurationSeconds: json['total_duration_seconds'] ?? 0,
      stageFresh: json['stage_fresh'] ?? 0,
      stageInterested: json['stage_interested'] ?? 0,
      stageCommitted: json['stage_committed'] ?? 0,
      stageNotInterested: json['stage_not_interested'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_calls': totalCalls,
      'incoming_calls': incomingCalls,
      'outgoing_calls': outgoingCalls,
      'missed_calls': missedCalls,
      'connected_calls': connectedCalls,
      'attempted_calls': attemptedCalls,
      'total_duration_seconds': totalDurationSeconds,
      'stage_fresh': stageFresh,
      'stage_interested': stageInterested,
      'stage_committed': stageCommitted,
      'stage_not_interested': stageNotInterested,
    };
  }
} 