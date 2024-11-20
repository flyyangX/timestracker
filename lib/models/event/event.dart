import 'package:flutter/material.dart';
import '../../screens/custom_event/models/custom_attribute.dart';

class Event {
  final String id;
  final String name;
  final IconData? icon;
  final String? emoji;
  final String? imagePath;
  final String category;
  final bool quickRecord;
  final List<CustomAttribute>? attributes;
  final DateTime? lastOccurrence;

  Event({
    required this.id,
    required this.name,
    this.icon,
    this.emoji,
    this.imagePath,
    required this.category,
    this.quickRecord = false,
    this.attributes,
    this.lastOccurrence,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon?.codePoint,
      'emoji': emoji,
      'imagePath': imagePath,
      'category': category,
      'quickRecord': quickRecord,
      'attributes': attributes?.map((a) => a.toJson()).toList(),
      'lastOccurrence': lastOccurrence?.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] != null
          ? IconData(json['icon'], fontFamily: 'MaterialIcons')
          : null,
      emoji: json['emoji'],
      imagePath: json['imagePath'],
      category: json['category'],
      quickRecord: json['quickRecord'] ?? false,
      attributes: (json['attributes'] as List?)
          ?.map((a) => CustomAttribute.fromJson(a))
          .toList(),
      lastOccurrence: json['lastOccurrence'] != null
          ? DateTime.parse(json['lastOccurrence'])
          : null,
    );
  }
}
