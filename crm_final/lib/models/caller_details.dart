class CallerDetails {
  final int? id;
  final int callerId;
  final int tasksLate;
  final int tasksPending;
  final int tasksDone;
  final int tasksCreated;
  final int whatsappIncoming;
  final int whatsappOutgoing;
  final int stageFresh;
  final int stageInterested;
  final int stageCommitted;
  final int stageNotInterested;
  final int stageNotConnected;
  final int stageCallback;
  final int stageTempleVisit;
  final int stageTempleDonor;
  final int stageLost;
  final int stageWon;
  final String? createdAt;

  CallerDetails({
    this.id,
    required this.callerId,
    required this.tasksLate,
    required this.tasksPending,
    required this.tasksDone,
    required this.tasksCreated,
    required this.whatsappIncoming,
    required this.whatsappOutgoing,
    required this.stageFresh,
    required this.stageInterested,
    required this.stageCommitted,
    required this.stageNotInterested,
    required this.stageNotConnected,
    required this.stageCallback,
    required this.stageTempleVisit,
    required this.stageTempleDonor,
    required this.stageLost,
    required this.stageWon,
    this.createdAt,
  });

  factory CallerDetails.fromJson(Map<String, dynamic> json) {
    return CallerDetails(
      id: json['id'],
      callerId: json['caller_id'],
      tasksLate: json['tasks_late'],
      tasksPending: json['tasks_pending'],
      tasksDone: json['tasks_done'],
      tasksCreated: json['tasks_created'],
      whatsappIncoming: json['whatsapp_incoming'],
      whatsappOutgoing: json['whatsapp_outgoing'],
      stageFresh: json['stage_fresh'],
      stageInterested: json['stage_interested'],
      stageCommitted: json['stage_committed'],
      stageNotInterested: json['stage_not_interested'],
      stageNotConnected: json['stage_not_connected'],
      stageCallback: json['stage_callback'],
      stageTempleVisit: json['stage_temple_visit'],
      stageTempleDonor: json['stage_temple_donor'],
      stageLost: json['stage_lost'],
      stageWon: json['stage_won'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caller_id': callerId,
      'tasks_late': tasksLate,
      'tasks_pending': tasksPending,
      'tasks_done': tasksDone,
      'tasks_created': tasksCreated,
      'whatsapp_incoming': whatsappIncoming,
      'whatsapp_outgoing': whatsappOutgoing,
      'stage_fresh': stageFresh,
      'stage_interested': stageInterested,
      'stage_committed': stageCommitted,
      'stage_not_interested': stageNotInterested,
      'stage_not_connected': stageNotConnected,
      'stage_callback': stageCallback,
      'stage_temple_visit': stageTempleVisit,
      'stage_temple_donor': stageTempleDonor,
      'stage_lost': stageLost,
      'stage_won': stageWon,
      'created_at': createdAt,
    };
  }
}
