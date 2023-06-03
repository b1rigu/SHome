import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String uid;
  final List<String> roomIds;
  UserModel({
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.roomIds,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? uid,
    List<String>? roomIds,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      roomIds: roomIds ?? this.roomIds,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'profilePic': profilePic});
    result.addAll({'uid': uid});
    result.addAll({'roomIds': roomIds});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      uid: map['uid'] ?? '',
      roomIds: List<String>.from(map['roomIds']),
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, uid: $uid, roomIds: $roomIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.uid == uid &&
        listEquals(other.roomIds, roomIds);
  }

  @override
  int get hashCode {
    return name.hashCode ^ profilePic.hashCode ^ uid.hashCode ^ roomIds.hashCode;
  }
}
