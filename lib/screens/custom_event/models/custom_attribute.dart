import 'attribute_type.dart';

class CustomAttribute {
  final String name;
  final AttributeType type;
  final List<String>? options;
  final Map<String, dynamic>? defaultValue;

  const CustomAttribute({
    required this.name,
    required this.type,
    this.options,
    this.defaultValue,
  });

  // 序列化方法
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.toString(), // 将枚举转换为字符串
        'options': options,
        'defaultValue': defaultValue,
      };

  // 反序列化方法
  factory CustomAttribute.fromJson(Map<String, dynamic> json) =>
      CustomAttribute(
        name: json['name'] as String,
        type: _parseAttributeType(json['type'] as String), // 将字符串转换为枚举
        options: (json['options'] as List<dynamic>?)?.cast<String>(),
        defaultValue: json['defaultValue'] as Map<String, dynamic>?,
      );

  // 辅助方法：解析属性类型字符串
  static AttributeType _parseAttributeType(String typeStr) {
    switch (typeStr) {
      case 'AttributeType.number':
        return AttributeType.number;
      case 'AttributeType.singleChoice':
        return AttributeType.singleChoice;
      case 'AttributeType.multipleChoice':
        return AttributeType.multipleChoice;
      case 'AttributeType.text':
        return AttributeType.text;
      case 'AttributeType.toggle':
        return AttributeType.toggle;
      case 'AttributeType.date':
        return AttributeType.date;
      default:
        throw ArgumentError('Unknown attribute type: $typeStr');
    }
  }
}
