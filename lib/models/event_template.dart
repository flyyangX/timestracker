import 'package:flutter/material.dart';
import '../screens/custom_event/models/custom_attribute.dart';

class EventTemplate {
  final String id;
  final String name;
  final String group;
  final IconData? icon;
  final String? emoji;
  final String? imagePath;
  final bool quickRecord;
  final bool periodicReminder;
  final bool missedReminder;
  final Map<String, dynamic>? reminderTime;
  final String? reminderFrequency;
  final List<CustomAttribute> attributes;
  final String description;

  const EventTemplate({
    required this.id,
    required this.name,
    required this.group,
    this.icon,
    this.emoji,
    this.imagePath,
    required this.quickRecord,
    required this.periodicReminder,
    required this.missedReminder,
    this.reminderTime,
    this.reminderFrequency,
    required this.attributes,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'icon': icon?.codePoint,
        'emoji': emoji,
        'imagePath': imagePath,
        'quickRecord': quickRecord,
        'periodicReminder': periodicReminder,
        'missedReminder': missedReminder,
        'reminderTime': reminderTime,
        'reminderFrequency': reminderFrequency,
        'attributes': attributes.map((attr) => attr.toJson()).toList(),
        'description': description,
      };

  factory EventTemplate.fromJson(Map<String, dynamic> json) => EventTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        group: json['group'] as String,
        icon: json['icon'] != null
            ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons')
            : null,
        emoji: json['emoji'] as String?,
        imagePath: json['imagePath'] as String?,
        quickRecord: json['quickRecord'] as bool,
        periodicReminder: json['periodicReminder'] as bool,
        missedReminder: json['missedReminder'] as bool,
        reminderTime: json['reminderTime'] as Map<String, dynamic>?,
        reminderFrequency: json['reminderFrequency'] as String?,
        attributes: (json['attributes'] as List<dynamic>)
            .map((e) => CustomAttribute.fromJson(e as Map<String, dynamic>))
            .toList(),
        description: json['description'] as String? ?? '',
      );
}
