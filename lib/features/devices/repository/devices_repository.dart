import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smarthomeuione/core/constants/firebase_constants.dart';
import 'package:smarthomeuione/core/failure.dart';
import 'package:smarthomeuione/core/providers/firebase_providers.dart';
import 'package:smarthomeuione/core/type_defs.dart';
import 'package:smarthomeuione/models/device_model.dart';
import 'package:smarthomeuione/models/signed_device_model.dart';

final devicesRepositoryProvider = Provider((ref) {
  return DevicesRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class DevicesRepository {
  final FirebaseFirestore _firestore;
  DevicesRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _signedDevices =>
      _firestore.collection(FirebaseConstants.signedDevicesCollection);

  FutureVoid createDevice(DeviceModel device, String uid) async {
    try {
      final deviceDoc = await _users
          .doc(uid)
          .collection(FirebaseConstants.devicesCollection)
          .doc(device.macId)
          .get();
      final signedDeviceModel = await _signedDevices
          .doc(device.macId)
          .get()
          .then((value) => SignedDeviceModel.fromMap(value.data() as Map<String, dynamic>));
      final type = signedDeviceModel.type;
      if (!deviceDoc.exists) {
        final docRef =
            _users.doc(uid).collection(FirebaseConstants.devicesCollection).doc(device.macId);
        return right(docRef.set(device.copyWith(type: type).toMap()));
      }
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteDevice(DeviceModel device, String uid) async {
    try {
      final docRef =
          _users.doc(uid).collection(FirebaseConstants.devicesCollection).doc(device.macId);
      return right(docRef.delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid changeDeviceName(DeviceModel device, String name, String uid) async {
    try {
      if (name.isEmpty) {
        throw 'Name cannot be empty';
      }
      final docRef =
          _users.doc(uid).collection(FirebaseConstants.devicesCollection).doc(device.macId);
      return right(docRef.update({'name': name}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<DeviceModel> getDeviceById(String deviceId, String uid) {
    return _users
        .doc(uid)
        .collection(FirebaseConstants.devicesCollection)
        .doc(deviceId)
        .snapshots()
        .map(
          (event) => DeviceModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  Stream<DeviceModel> getDeviceByMacId(String macId, String uid) {
    return _users
        .doc(uid)
        .collection(FirebaseConstants.devicesCollection)
        .doc(macId)
        .snapshots()
        .map(
          (event) => DeviceModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  Stream<List<DeviceModel>> getUserDevices(String uid) {
    return _users.doc(uid).collection(FirebaseConstants.devicesCollection).snapshots().map((event) {
      List<DeviceModel> rooms = [];
      rooms.addAll(event.docs.map((e) => DeviceModel.fromMap(e.data())));
      return rooms;
    });
  }
}
