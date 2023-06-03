import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/providers/refresh_provider.dart';
import 'package:smarthomeuione/core/utils.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/features/devices/repository/devices_repository.dart';
import 'package:smarthomeuione/models/device_model.dart';

final userDevicesProvider = StreamProvider((ref) {
  ref.watch(refreshProvider);
  final devicesController = ref.watch(devicesControllerProvider.notifier);
  return devicesController.getUserDevices();
});

final getDeviceByIdProvider = StreamProvider.family((ref, String deviceId) {
  return ref.watch(devicesControllerProvider.notifier).getDeviceById(deviceId);
});

final getDeviceByMacIdProvider = StreamProvider.family((ref, String macId) {
  return ref.watch(devicesControllerProvider.notifier).getDeviceByMacId(macId);
});

final devicesControllerProvider = StateNotifierProvider<DevicesController, bool>((ref) {
  final devicesRepository = ref.watch(devicesRepositoryProvider);
  return DevicesController(devicesRepository: devicesRepository, ref: ref);
});

class DevicesController extends StateNotifier<bool> {
  final DevicesRepository _devicesRepository;
  final Ref _ref;
  DevicesController({
    required DevicesRepository devicesRepository,
    required Ref ref,
  })  : _devicesRepository = devicesRepository,
        _ref = ref,
        super(false);

  void createDevice(String macId, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    DeviceModel device = DeviceModel(
      macId: macId,
      name: 'Plug',
      type: '',
      consumption: 0,
      scheduleOn: [],
      scheduleOff: [],
    );
    final res = await _devicesRepository.createDevice(device, uid);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Device added successfully');
      Routemaster.of(context).pop();
    });
  }

  void deleteDevice(DeviceModel device, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;

    final res = await _devicesRepository.deleteDevice(device, uid);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Deleted successfully');
      //Routemaster.of(context).pop();
    });
  }

  void changeDeviceName(DeviceModel device, String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;

    final res = await _devicesRepository.changeDeviceName(device, name, uid);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Name changed successfully');
      //Routemaster.of(context).pop();
    });
  }

  Stream<DeviceModel> getDeviceByMacId(String macId) {
    final uid = _ref.read(userProvider)!.uid;
    return _devicesRepository.getDeviceByMacId(macId, uid);
  }

  Stream<DeviceModel> getDeviceById(String deviceId) {
    final uid = _ref.read(userProvider)!.uid;
    return _devicesRepository.getDeviceById(deviceId, uid);
  }

  Stream<List<DeviceModel>> getUserDevices() {
    final uid = _ref.read(userProvider)!.uid;
    return _devicesRepository.getUserDevices(uid);
  }
}
