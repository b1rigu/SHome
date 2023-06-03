class SignedDeviceModel {
  String macId;
  String type;
  SignedDeviceModel({
    required this.macId,
    required this.type,
  });

  SignedDeviceModel copyWith({
    String? macId,
    String? type,
  }) {
    return SignedDeviceModel(
      macId: macId ?? this.macId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'macId': macId});
    result.addAll({'type': type});

    return result;
  }

  factory SignedDeviceModel.fromMap(Map<String, dynamic> map) {
    return SignedDeviceModel(
      macId: map['macId'] ?? '',
      type: map['type'] ?? '',
    );
  }

  @override
  String toString() => 'SignedDeviceModel(macId: $macId, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SignedDeviceModel && other.macId == macId && other.type == type;
  }

  @override
  int get hashCode => macId.hashCode ^ type.hashCode;
}
