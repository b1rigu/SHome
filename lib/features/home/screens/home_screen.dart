import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/core/enums/enums.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/features/home/widgets/device_card.dart';
import 'package:smarthomeuione/features/home/widgets/room_card.dart';
import 'package:smarthomeuione/features/mqtt/repository/mqtt_repository.dart';
import 'package:smarthomeuione/features/room/controller/room_controller.dart';
import 'package:smarthomeuione/models/device_model.dart';
import 'package:smarthomeuione/models/room_model.dart';
import 'package:smarthomeuione/responsive/responsive.dart';
import 'package:smarthomeuione/theme/palette.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final yourScrollController = ScrollController();
  final Location location = Location();
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  late MQTTRepository mqttRepo;
  bool roomselected = true;

  @override
  void initState() {
    super.initState();
    mqttConnect();
  }

  @override
  void dispose() {
    yourScrollController.dispose();
    super.dispose();
  }

  void mqttConnect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mqttRepo = ref.read(mqttProvider);
      if (!mqttRepo.isConnected()) {
        mqttRepo.initializeMQTTClient();
        mqttRepo.connect();
      }
    });
  }

  void navigateToAddDeviceOrRoom(BuildContext context, String value) async {
    if (value == 'room') {
      Routemaster.of(context).push('/room-add');
    } else {
      await location.requestPermission();
      if (await location.hasPermission() == PermissionStatus.granted) {
        if (!await location.serviceEnabled()) {
          bool isYes =
              await openDialog('About location', 'You have to turn on location to add device');
          if (isYes) await AppSettings.openLocationSettings();
        }
        if (!await flutterBlue.isOn) {
          bool isYes =
              await openDialog('About bluetooth', 'You have to turn on bluetooth to add device');
          if (isYes) await AppSettings.openBluetoothSettings();
        }
        if (await location.serviceEnabled() && await flutterBlue.isOn) {
          if (!mounted) return;
          Routemaster.of(context).push('/device-add');
        }
      }
    }
  }

  Future openDialog(String title, String description) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'No',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mqttState = ref.watch(mqttStateProvider);
    final safePadding = MediaQuery.of(context).padding.top;

    return Responsive(
      child: mqttState == MqttAppConnectionState.connecting
          ? const Loader()
          : Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome Home',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // smart devices and rooms select button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SelectButton(
                              isRoom: true,
                              roomselected: roomselected,
                              onPressed: () => setState(() => roomselected = true),
                            ),
                            SelectButton(
                              isRoom: false,
                              roomselected: roomselected,
                              onPressed: () => setState(() => roomselected = false),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        icon: const Icon(Icons.add),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'room',
                            child: Text('Add a room'),
                          ),
                          PopupMenuItem(
                            value: 'device',
                            child: Text('Add a device'),
                          ),
                        ],
                        onSelected: (value) => navigateToAddDeviceOrRoom(context, value),
                      ),
                    ],
                  ),
                  // smart devices or rooms
                  const SizedBox(height: 20),
                  ref.watch(roomselected ? userRoomsProvider : userDevicesProvider).when(
                        data: (data) {
                          return Expanded(
                            child: Scrollbar(
                              controller: yourScrollController,
                              thumbVisibility: true,
                              interactive: true,
                              child: ListView.builder(
                                controller: yourScrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: roomselected
                                        ? RoomCard(room: data[index] as RoomModel)
                                        : DeviceCard(device: data[index] as DeviceModel),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        error: (error, _) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}

class SelectButton extends StatelessWidget {
  const SelectButton({
    super.key,
    required this.onPressed,
    required this.roomselected,
    required this.isRoom,
  });

  final VoidCallback? onPressed;
  final bool roomselected;
  final bool isRoom;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            isRoom
                ? roomselected
                    ? Pallete.primaryMainColor
                    : Colors.transparent
                : roomselected
                    ? Colors.transparent
                    : Pallete.primaryMainColor,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60.0),
            ),
          ),
          elevation: MaterialStateProperty.all<double>(0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            isRoom ? 'Rooms' : 'Devices',
            style: TextStyle(
              color: isRoom
                  ? roomselected
                      ? Colors.white
                      : Colors.black
                  : roomselected
                      ? Colors.black
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
