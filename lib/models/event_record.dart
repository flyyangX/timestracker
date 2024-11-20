class EventRecord {
  final String id;
  final String eventId;
  final DateTime timestamp;
  final Map<String, dynamic> attributeValues;
  final String? note;

  EventRecord({
    required this.id,
    required this.eventId,
    required this.timestamp,
    required this.attributeValues,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'timestamp': timestamp.toIso8601String(),
      'attributeValues': attributeValues,
      'note': note,
    };
  }

  factory EventRecord.fromJson(Map<String, dynamic> json) {
    return EventRecord(
      id: json['id'],
      eventId: json['eventId'],
      timestamp: DateTime.parse(json['timestamp']),
      attributeValues: Map<String, dynamic>.from(json['attributeValues']),
      note: json['note'],
    );
  }
}
