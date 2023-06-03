import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/models/device_model.dart';
import 'package:smarthomeuione/theme/palette.dart';

import '../../../core/common/loader.dart';

class ScheduleDeviceCard extends ConsumerStatefulWidget {
  final DeviceModel device;
  const ScheduleDeviceCard({super.key, required this.device});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScheduleDeviceCardState();
}

class _ScheduleDeviceCardState extends ConsumerState<ScheduleDeviceCard> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void navigateToConfigure(BuildContext context) {
    Routemaster.of(context).push('/schedule-configure/${widget.device.macId}');
  }

  Future changeDeviceName() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change name'),
          content: TextField(
            autofocus: true,
            controller: nameController,
            maxLength: 25,
            decoration: const InputDecoration(
              hintText: 'Enter the name',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => submit(),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

  void submit() {
    ref
        .read(devicesControllerProvider.notifier)
        .changeDeviceName(widget.device, nameController.text.trim(), context);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    return GestureDetector(
      onLongPress: () {
        changeDeviceName();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //room icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.plugCircleBolt,
                      color: Colors.blue,
                    ),
                  ),
                ),

                SizedBox(
                  width: 160,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => navigateToConfigure(context),
                    style: TextButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Pallete.primaryMainColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'View Schedules',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '⚡ Not consuming',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref('devices/${widget.device.macId}/schedule')
                      .onValue,
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return const Loader();
                    }
                    if (snapshot.data!.snapshot.value != null) {
                      final data = snapshot.data!.snapshot.value as String;
                      List<String> schedules = data.split(',');
                      return Row(
                        children: [
                          const Text(
                            "Total schedules: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(schedules.length.toString()),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
