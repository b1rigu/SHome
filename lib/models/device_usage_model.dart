class DeviceUsageModel {
  DateTime dataTime;
  double usageSum;
  DeviceUsageModel({
    required this.dataTime,
    required this.usageSum,
  });

  DeviceUsageModel copyWith({
    DateTime? dataTime,
    double? usageSum,
  }) {
    return DeviceUsageModel(
      dataTime: dataTime ?? this.dataTime,
      usageSum: usageSum ?? this.usageSum,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'dataTime': dataTime.millisecondsSinceEpoch});
    result.addAll({'usageSum': usageSum});

    return result;
  }

  factory DeviceUsageModel.fromMap(Map<String, dynamic> map) {
    return DeviceUsageModel(
      dataTime: DateTime.fromMillisecondsSinceEpoch(map['dataTime']),
      usageSum: double.parse(map['usageSum']),
    );
  }

  @override
  String toString() => 'DeviceUsageModel(dataTime: $dataTime, usageSum: $usageSum)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceUsageModel && other.dataTime == dataTime && other.usageSum == usageSum;
  }

  @override
  int get hashCode => dataTime.hashCode ^ usageSum.hashCode;
}
