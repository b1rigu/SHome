import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/providers/refresh_provider.dart';
import 'package:smarthomeuione/core/utils.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/features/room/repository/room_repository.dart';
import 'package:smarthomeuione/models/room_model.dart';

final userRoomsProvider = StreamProvider((ref) {
  ref.watch(refreshProvider);
  final roomController = ref.watch(roomControllerProvider.notifier);
  return roomController.getUserRooms();
});

final getRoomByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(roomControllerProvider.notifier).getRoomByName(name);
});

final getRoomByIdProvider = StreamProvider.family((ref, String roomId) {
  return ref.watch(roomControllerProvider.notifier).getRoomById(roomId);
});

final roomControllerProvider = StateNotifierProvider<RoomController, bool>((ref) {
  final roomRepository = ref.watch(roomRepositoryProvider);
  return RoomController(roomRepository: roomRepository, ref: ref);
});

class RoomController extends StateNotifier<bool> {
  final RoomRepository _roomRepository;
  final Ref _ref;
  RoomController({
    required RoomRepository roomRepository,
    required Ref ref,
  })  : _roomRepository = roomRepository,
        _ref = ref,
        super(false);

  void createRoom(String name, int icon, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    RoomModel room = RoomModel(
      roomId: '',
      name: name,
      icon: icon,
      deviceMacs: [],
    );
    final res = await _roomRepository.createRoom(room, uid);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Room created successfully');
      Routemaster.of(context).pop();
    });
  }

  void changeRoomName(RoomModel room, String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    final res = await _roomRepository.changeRoomName(room, name, uid);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Name changed successfully');
      //Routemaster.of(context).pop();
    });
  }

  void deleteRoom(RoomModel room, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    final res = await _roomRepository.deleteRoom(room, uid);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Deleted successfully');
      Routemaster.of(context).pop();
    });
  }

  void addDeviceInRoom(String roomId, List<String> macs, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    final res = await _roomRepository.addDeviceInRoom(roomId, uid, macs);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<RoomModel> getRoomByName(String name) {
    final uid = _ref.read(userProvider)!.uid;
    return _roomRepository.getRoomByName(name, uid);
  }

  Stream<RoomModel> getRoomById(String roomId) {
    final uid = _ref.read(userProvider)!.uid;
    return _roomRepository.getRoomById(roomId, uid);
  }

  Stream<List<RoomModel>> getUserRooms() {
    final uid = _ref.read(userProvider)!.uid;
    return _roomRepository.getUserRooms(uid);
  }
}
