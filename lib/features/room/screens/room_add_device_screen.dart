import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/features/room/controller/room_controller.dart';
import 'package:smarthomeuione/theme/palette.dart';

class RoomAddDeviceScreen extends ConsumerStatefulWidget {
  final String roomId;
  const RoomAddDeviceScreen({super.key, required this.roomId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoomAddDeviceScreenState();
}

class _RoomAddDeviceScreenState extends ConsumerState<RoomAddDeviceScreen> {
  Set<String> macs = {};
  int counter = 0;

  void addMac(String mac) {
    setState(() {
      macs.add(mac);
    });
  }

  void removeMac(String mac) {
    setState(() {
      macs.remove(mac);
    });
  }

  void saveMacs() {
    ref
        .read(roomControllerProvider.notifier)
        .addDeviceInRoom(widget.roomId, macs.toList(), context);
  }

  void navigateBack() {
    Routemaster.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    final theme = ref.watch(themeNotifierProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.only(left: 28, right: 28, top: safePadding + 16),
        child: Column(
          children: [
            // custom app bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Ink(
                  width: 50,
                  height: 50,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    onPressed: () => navigateBack(),
                    splashRadius: 25,
                    icon: const FaIcon(
                      FontAwesomeIcons.chevronLeft,
                      size: 18,
                    ),
                  ),
                ),
                const Text(
                  'Add Device in Room',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Ink(
                  width: 50,
                  height: 50,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    onPressed: () => saveMacs(),
                    splashRadius: 25,
                    icon: const Icon(
                      Icons.done,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            ref.watch(getRoomByIdProvider(widget.roomId)).when(
                  data: (room) => ref.watch(userDevicesProvider).when(
                        data: (devices) => Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              if (room.deviceMacs.contains(devices[index].macId) &&
                                  counter <= room.deviceMacs.length) {
                                macs.add(devices[index].macId);
                              }
                              counter++;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: CheckboxListTile(
                                  value: macs.contains(devices[index].macId),
                                  onChanged: (val) {
                                    if (val!) {
                                      addMac(devices[index].macId);
                                    } else {
                                      removeMac(devices[index].macId);
                                    }
                                  },
                                  title: Text(devices[index].name),
                                  tileColor: theme.cardBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            },
                          ),
                        ),
                        error: (error, _) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                  error: (error, _) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ],
        ),
      ),
    );
  }
}
