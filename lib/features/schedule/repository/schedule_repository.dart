import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smarthomeuione/core/constants/firebase_constants.dart';
import 'package:smarthomeuione/core/failure.dart';
import 'package:smarthomeuione/core/providers/firebase_providers.dart';
import 'package:smarthomeuione/core/type_defs.dart';
import 'package:smarthomeuione/models/device_model.dart';

final scheduleRepositoryProvider = Provider((ref) {
  return ScheduleRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class ScheduleRepository {
  final FirebaseFirestore _firestore;
  ScheduleRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid createSchedule(String deviceId, String uid, String time, bool isOn) async {
    try {
      final docRef = _users.doc(uid).collection(FirebaseConstants.devicesCollection).doc(deviceId);
      if (isOn) {
        return right(docRef.update({
          'scheduleOn': FieldValue.arrayUnion([time])
        }));
      }
      return right(docRef.update({
        'scheduleOff': FieldValue.arrayUnion([time])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteSchedule(String deviceId, String uid, String time, bool isOn) async {
    try {
      final docRef = _users.doc(uid).collection(FirebaseConstants.devicesCollection).doc(deviceId);
      if (isOn) {
        return right(docRef.update({
          'scheduleOn': FieldValue.arrayRemove([time])
        }));
      }
      return right(docRef.update({
        'scheduleOff': FieldValue.arrayRemove([time])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<String> getMacbyDeviceId(String deviceId, String uid) async {
    final docRef = _users.doc(uid).collection(FirebaseConstants.devicesCollection).doc(deviceId);
    final doc = await docRef.get().then((value) => value.data());
    DeviceModel device = DeviceModel.fromMap(doc!);
    return device.macId;
  }
}
