import 'package:flutter/foundation.dart';

class DeviceModel {
  final String macId;
  final String name;
  final String type;
  final double consumption;
  final List<String> scheduleOn;
  final List<String> scheduleOff;
  DeviceModel({
    required this.macId,
    required this.name,
    required this.type,
    required this.consumption,
    required this.scheduleOn,
    required this.scheduleOff,
  });

  DeviceModel copyWith({
    String? macId,
    String? name,
    String? type,
    double? consumption,
    List<String>? scheduleOn,
    List<String>? scheduleOff,
  }) {
    return DeviceModel(
      macId: macId ?? this.macId,
      name: name ?? this.name,
      type: type ?? this.type,
      consumption: consumption ?? this.consumption,
      scheduleOn: scheduleOn ?? this.scheduleOn,
      scheduleOff: scheduleOff ?? this.scheduleOff,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'macId': macId});
    result.addAll({'name': name});
    result.addAll({'type': type});
    result.addAll({'consumption': consumption});
    result.addAll({'scheduleOn': scheduleOn});
    result.addAll({'scheduleOff': scheduleOff});

    return result;
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      macId: map['macId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      consumption: map['consumption']?.toDouble() ?? 0.0,
      scheduleOn: List<String>.from(map['scheduleOn']),
      scheduleOff: List<String>.from(map['scheduleOff']),
    );
  }

  @override
  String toString() {
    return 'DeviceModel(macId: $macId, name: $name, type: $type, consumption: $consumption, scheduleOn: $scheduleOn, scheduleOff: $scheduleOff)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceModel &&
        other.macId == macId &&
        other.name == name &&
        other.type == type &&
        other.consumption == consumption &&
        listEquals(other.scheduleOn, scheduleOn) &&
        listEquals(other.scheduleOff, scheduleOff);
  }

  @override
  int get hashCode {
    return macId.hashCode ^
        name.hashCode ^
        type.hashCode ^
        consumption.hashCode ^
        scheduleOn.hashCode ^
        scheduleOff.hashCode;
  }
}
