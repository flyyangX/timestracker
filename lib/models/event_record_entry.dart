import 'package:flutter/material.dart';
import 'field_value.dart';

class EventRecordEntry {
  final String id;
  final String eventId;
  final DateTime timestamp;
  final String location;
  final String? note;
  final double? duration;
  final int? mood;
  final bool isImportant;
  final List<String>? tags;
  final Map<String, FieldValue> attributeValues;
  final List<String>? images;

  EventRecordEntry({
    required this.id,
    required this.eventId,
    required this.timestamp,
    this.location = '',
    this.note,
    this.duration,
    this.mood,
    this.isImportant = false,
    this.tags,
    required this.attributeValues,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'note': note,
      'duration': duration?.toString(),
      'mood': mood?.toString(),
      'isImportant': isImportant.toString(),
      'tags': tags,
      'attributeValues': attributeValues.map(
        (key, value) => MapEntry(
          key,
          {
            'value': value.value.toString(),
            'visible': value.visible,
          },
        ),
      ),
      'images': images,
    };
  }

  factory EventRecordEntry.fromJson(Map<String, dynamic> json) {
    return EventRecordEntry(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String? ?? '',
      note: json['note'] as String?,
      duration: json['duration'] != null
          ? double.tryParse(json['duration'] as String)
          : null,
      mood: json['mood'] != null ? int.tryParse(json['mood'] as String) : null,
      isImportant: json['isImportant'] == 'true',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      attributeValues: (json['attributeValues'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          FieldValue(
            value: (value as Map<String, dynamic>)['value'] as String,
            visible: (value)['visible'] as bool,
          ),
        ),
      ),
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
    );
  }

  IconData getMoodIcon() {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color getMoodColor() {
    switch (mood) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getFormattedDuration() {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration!.toInt() % 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }
}
