import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/utils.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/features/schedule/repository/schedule_repository.dart';

final scheduleControllerProvider = StateNotifierProvider<ScheduleController, bool>((ref) {
  final scheduleRepository = ref.watch(scheduleRepositoryProvider);
  return ScheduleController(scheduleRepository: scheduleRepository, ref: ref);
});

class ScheduleController extends StateNotifier<bool> {
  final ScheduleRepository _scheduleRepository;
  final Ref _ref;
  ScheduleController({
    required ScheduleRepository scheduleRepository,
    required Ref ref,
  })  : _scheduleRepository = scheduleRepository,
        _ref = ref,
        super(false);

  void createSchedule(String deviceId, BuildContext context, String time, bool isOn) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    final res = await _scheduleRepository.createSchedule(deviceId, uid, time, isOn);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Schedule created successfully');
      Routemaster.of(context).pop();
    });
  }

  void deleteSchedule(String deviceId, BuildContext context, String time, bool isOn) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    final res = await _scheduleRepository.deleteSchedule(deviceId, uid, time, isOn);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Schedule deleted successfully');
      Routemaster.of(context).pop();
    });
  }

  Future<String> getMacbyDeviceId(String deviceId, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    final macId = await _scheduleRepository.getMacbyDeviceId(deviceId, uid);
    state = false;
    return macId;
  }
}
