import 'package:flutter/foundation.dart';

class RoomModel {
  final String roomId;
  final String name;
  final int icon;
  final List<String> deviceMacs;
  RoomModel({
    required this.roomId,
    required this.name,
    required this.icon,
    required this.deviceMacs,
  });

  RoomModel copyWith({
    String? roomId,
    String? name,
    int? icon,
    List<String>? deviceMacs,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      deviceMacs: deviceMacs ?? this.deviceMacs,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'roomId': roomId});
    result.addAll({'name': name});
    result.addAll({'icon': icon});
    result.addAll({'deviceMacs': deviceMacs});

    return result;
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomId: map['roomId'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon']?.toInt() ?? 0,
      deviceMacs: List<String>.from(map['deviceMacs']),
    );
  }

  @override
  String toString() {
    return 'RoomModel(roomId: $roomId, name: $name, icon: $icon, deviceMacs: $deviceMacs)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoomModel &&
        other.roomId == roomId &&
        other.name == name &&
        other.icon == icon &&
        listEquals(other.deviceMacs, deviceMacs);
  }

  @override
  int get hashCode {
    return roomId.hashCode ^ name.hashCode ^ icon.hashCode ^ deviceMacs.hashCode;
  }
}
