import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/features/devices/screens/smart_plug.dart';
import 'package:smarthomeuione/features/room/controller/room_controller.dart';
import 'package:smarthomeuione/models/room_model.dart';
import 'package:smarthomeuione/responsive/responsive.dart';
import 'package:smarthomeuione/theme/palette.dart';

class RoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  final nameController = TextEditingController();
  int selectedDeviceIndex = 0;

  void navigateBack() {
    Routemaster.of(context).pop();
  }

  void onSelected(RoomModel room, String value) {
    if (value == 'change') {
      changeRoomName(room);
    } else {
      deleteRoom(room);
    }
  }

  void navigateToRoomAddScreen() {
    Routemaster.of(context).push('/room-add-device/${widget.roomId}');
  }

  Future changeRoomName(RoomModel room) => showDialog(
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
              onPressed: () => submit(room),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

  void submit(RoomModel room) {
    ref
        .read(roomControllerProvider.notifier)
        .changeRoomName(room, nameController.text.trim(), context);
    Navigator.of(context).pop();
  }

  Future deleteRoom(RoomModel room) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('You are going to delete this room permanently'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => delete(room),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

  void delete(RoomModel room) {
    ref.read(roomControllerProvider.notifier).deleteRoom(room, context);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Responsive(
        child: ref.watch(getRoomByIdProvider(widget.roomId)).when(
              data: (room) {
                return Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16),
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
                          Text(
                            room.name,
                            style: const TextStyle(
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
                            child: PopupMenuButton(
                              splashRadius: 25,
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              icon: const FaIcon(
                                FontAwesomeIcons.ellipsis,
                                size: 18,
                              ),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'change',
                                  child: Text('Change name'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete room'),
                                ),
                              ],
                              onSelected: (value) => onSelected(room, value),
                            ),
                          ),
                        ],
                      ),
                      // devices that are in the selected room
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: room.deviceMacs.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == room.deviceMacs.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () => navigateToRoomAddScreen(),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: const Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.penToSquare,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ref.watch(getDeviceByMacIdProvider(room.deviceMacs[index])).when(
                                  data: (device) {
                                    if (index == selectedDeviceIndex) {
                                      if (device.type == 'Plug') {
                                        return SmartPlugSelect(
                                          onPressed: () {},
                                          selected: true,
                                        );
                                      }
                                    } else {
                                      if (device.type == 'Plug') {
                                        return SmartPlugSelect(
                                          onPressed: () =>
                                              setState(() => selectedDeviceIndex = index),
                                        );
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  error: (error, _) => ErrorText(error: error.toString()),
                                  loading: () => const Loader(),
                                );
                          },
                        ),
                      ),
                      //device specific control one
                      const SizedBox(height: 20),
                      if (room.deviceMacs.isNotEmpty)
                        ref
                            .watch(getDeviceByMacIdProvider(room.deviceMacs[selectedDeviceIndex]))
                            .when(
                              data: (device) {
                                if (device.type == 'Plug') {
                                  return SmartPlug(macId: room.deviceMacs[selectedDeviceIndex]);
                                }
                                return const SizedBox.shrink();
                              },
                              error: (error, _) => ErrorText(error: error.toString()),
                              loading: () => const Loader(),
                            ),
                    ],
                  ),
                );
              },
              error: (error, _) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}

class SmartPlugSelect extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool selected;
  const SmartPlugSelect({
    super.key,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Pallete.primaryMainColor.withOpacity(0.5) : Colors.white,
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.plugCircleBolt,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Plug',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
