class FieldValue {
  final dynamic value;
  final bool visible;

  FieldValue({
    required this.value,
    this.visible = true,
  });

  Map<String, dynamic> toJson() => {
        'value': value.toString(),
        'visible': visible,
      };

  factory FieldValue.fromJson(Map<String, dynamic> json) => FieldValue(
        value: json['value'] as String,
        visible: json['visible'] as bool,
      );
}
