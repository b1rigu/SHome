import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smarthomeuione/core/constants/firebase_constants.dart';
import 'package:smarthomeuione/core/failure.dart';
import 'package:smarthomeuione/core/providers/firebase_providers.dart';
import 'package:smarthomeuione/core/type_defs.dart';
import 'package:smarthomeuione/models/room_model.dart';

final roomRepositoryProvider = Provider((ref) {
  return RoomRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class RoomRepository {
  final FirebaseFirestore _firestore;
  RoomRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid createRoom(RoomModel room, String uid) async {
    try {
      if (room.name.isEmpty) {
        throw 'Room name cannot be empty';
      }
      final docRef = _users.doc(uid).collection(FirebaseConstants.roomsCollection).doc();
      return right(docRef.set(room.copyWith(roomId: docRef.id).toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid changeRoomName(RoomModel room, String name, String uid) async {
    try {
      if (name.isEmpty) {
        throw 'Name cannot be empty';
      }
      final docRef = _users.doc(uid).collection(FirebaseConstants.roomsCollection).doc(room.roomId);
      return right(docRef.update({'name': name}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteRoom(RoomModel room, String uid) async {
    try {
      final docRef = _users.doc(uid).collection(FirebaseConstants.roomsCollection).doc(room.roomId);
      return right(docRef.delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addDeviceInRoom(String roomId, String uid, List<String> macs) async {
    try {
      final docRef = _users.doc(uid).collection(FirebaseConstants.roomsCollection).doc(roomId);
      return right(docRef.update({
        'deviceMacs': macs,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<RoomModel> getRoomByName(String name, String uid) {
    return _users
        .doc(uid)
        .collection(FirebaseConstants.roomsCollection)
        .where('name', isEqualTo: name)
        .snapshots()
        .map(
          (event) => RoomModel.fromMap(event.docs.first.data()),
        );
  }

  Stream<RoomModel> getRoomById(String roomId, String uid) {
    return _users
        .doc(uid)
        .collection(FirebaseConstants.roomsCollection)
        .doc(roomId)
        .snapshots()
        .map(
          (event) => RoomModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  Stream<List<RoomModel>> getUserRooms(String uid) {
    return _users.doc(uid).collection(FirebaseConstants.roomsCollection).snapshots().map((event) {
      List<RoomModel> rooms = [];
      rooms.addAll(event.docs.map((e) => RoomModel.fromMap(e.data())));
      return rooms;
    });
  }
}
