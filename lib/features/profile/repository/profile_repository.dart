import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smarthomeuione/core/constants/firebase_constants.dart';
import 'package:smarthomeuione/core/providers/firebase_providers.dart';
import 'package:smarthomeuione/core/providers/refresh_provider.dart';
import 'package:smarthomeuione/models/device_usage_model.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(
    firestore: ref.watch(firestoreProvider),
    realtimeDatabase: ref.watch(realtimeDatabaseProvider),
  );
});

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _realtimeDatabase;
  ProfileRepository(
      {required FirebaseFirestore firestore, required FirebaseDatabase realtimeDatabase})
      : _firestore = firestore,
        _realtimeDatabase = realtimeDatabase;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  Stream<Map<String, dynamic>> getGraphDataStream() {
    return _realtimeDatabase.ref('devices/686725B654D8/data').onValue.map((event) {
      List<DeviceUsageModel> deviceUsageList = [];
      if (event.snapshot.value != null) {
        final data = Map<String, String>.from(event.snapshot.value as Map);
        final totalSumStringList = data['totalSum']!.split(",");
        final dataTimeStringList = data['dataTime']!.split(",");
        if (totalSumStringList.length == dataTimeStringList.length) {
          for (int i = 0; i < totalSumStringList.length; i++) {
            deviceUsageList.add(
              DeviceUsageModel(
                dataTime: DateTime.fromMillisecondsSinceEpoch(int.parse(dataTimeStringList[i])),
                usageSum: double.parse(totalSumStringList[i]),
              ),
            );
          }
        }
      }
      //put todays data in list
      //put this months data in list
      List<DeviceUsageModel> deviceUsageListOfToday = [];
      List<DeviceUsageModel> deviceUsageListOfThisMonth = [];
      for (var deviceusage in deviceUsageList) {
        if (DateTime.now().eqvDay(deviceusage.dataTime)) {
          deviceUsageListOfToday.add(deviceusage);
        }
        if (DateTime.now().eqvMonth(deviceusage.dataTime)) {
          deviceUsageListOfThisMonth.add(deviceusage);
        }
      }

      double usageOfToday = 0.0;
      if (deviceUsageListOfToday.isNotEmpty) {
        //find max min value
        double minToday = deviceUsageListOfToday.first.usageSum;
        double maxToday = deviceUsageListOfToday.last.usageSum;
        //subtract and find todays usage
        usageOfToday = maxToday - minToday;
      }

      double usageOfThisMonth = 0.0;
      if (deviceUsageListOfThisMonth.isNotEmpty) {
        //find max min value
        double minMonth = deviceUsageListOfThisMonth.first.usageSum;
        double maxMonth = deviceUsageListOfThisMonth.last.usageSum;
        //subtract and find todays usage
        usageOfThisMonth = maxMonth - minMonth;
      }

      double tugrug = usageOfToday * 140;

      Map<String, dynamic> map = {
        'deviceUsageList': deviceUsageList,
        'usageOfToday': usageOfToday,
        'usageOfThisMonth': usageOfThisMonth,
        'urtug': tugrug,
      };

      return map;
    });
  }
}
