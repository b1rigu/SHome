import 'dart:async';
import 'dart:convert' show utf8;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/enums/enums.dart';
import 'package:smarthomeuione/core/utils.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/responsive/responsive.dart';
import 'package:smarthomeuione/theme/palette.dart';

class DeviceAddScreen extends ConsumerStatefulWidget {
  const DeviceAddScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeviceAddScreenState();
}

class _DeviceAddScreenState extends ConsumerState<DeviceAddScreen> {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  final String serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  final String statusCharacteristicUuid = 'b78128c8-cf94-11ed-afa1-0242ac120002';
  final String ssidCharacteristicUuid = 'b781242c-cf94-11ed-afa1-0242ac120002';
  final String passCharacteristicUuid = 'b781271a-cf94-11ed-afa1-0242ac120002';
  final String macCharacteristicUuid = '900dd580-d123-11ed-afa1-0242ac120002';
  String macAddress = '';
  BluetoothCharacteristic? ssidCharacteristic;
  BluetoothCharacteristic? passCharacteristic;
  BluetoothCharacteristic? statusCharacteristic;
  BluetoothCharacteristic? macCharacteristic;
  final String targetDevicePrefix = 'SHome';
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> bluetoothDevicesFound = [];
  StreamSubscription<List<ScanResult>>? scanSubscription;
  final NetworkInfo info = NetworkInfo();
  String connectionText = '';
  Enum setupStep = AddDeviceSteps.stepOne;
  bool isPassVisible = false;
  bool isScanning = false;
  bool isDeviceConnected = false;
  bool isCredentialsSent = false;
  bool isConnectedToServer = false;
  bool isDeviceInfoGotten = false;
  late Timer _timer;

  @override
  void dispose() {
    super.dispose();
    stopScan();
    ssidController.dispose();
    passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    String ssid = await info.getWifiName() ?? '';
    ssidController.text = ssid.replaceAll(RegExp('"'), '');
    scanDevices();
  }

  void scanDevices() async {
    setState(() {
      connectionText = 'Start scanning';
      isScanning = true;
    });
    flutterBlue.setLogLevel(LogLevel.warning);
    bluetoothDevicesFound = [];
    await flutterBlue.startScan(timeout: const Duration(seconds: 5));
    bluetoothDevicesFound = await flutterBlue.scanResults.first;
    setState(() {
      connectionText = 'Scan done';
      isScanning = false;
    });
  }

  void connectToDevice(BluetoothDevice? device) async {
    if (device == null) return;
    bool deviceExists = await flutterBlue.connectedDevices.then((value) => value.contains(device));
    if (!deviceExists) {
      await device.connect();
    }
    setState(() => isDeviceConnected = true);
    sendCredentials(device);
  }

  void disconnectFromDevice(BluetoothDevice? device) {
    if (device == null) return;
    device.disconnect();
  }

  void sendCredentials(BluetoothDevice? device) async {
    if (device == null) return;

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == ssidCharacteristicUuid) {
            ssidCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() == passCharacteristicUuid) {
            passCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() == statusCharacteristicUuid) {
            statusCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() == macCharacteristicUuid) {
            macCharacteristic = characteristic;
          }
        }
        final macAddressread = await macCharacteristic!.read();
        macAddress = utf8.decode(macAddressread);
        setState(() => isDeviceInfoGotten = true);
        await writeData(ssidController.text.trim(), ssidCharacteristic);
        await writeData(passwordController.text.trim(), passCharacteristic);
        setState(() => isCredentialsSent = true);
        await statusCharacteristic!.read();
        _timer = Timer.periodic(const Duration(milliseconds: 300), (_) async {
          final value = await statusCharacteristic!.read();
          final valuestr = utf8.decode(value);
          if (valuestr == 'Connected') {
            setState(() => isConnectedToServer = true);
            _timer.cancel();
            if (!mounted) return;
            ref.read(devicesControllerProvider.notifier).createDevice(macAddress, context);
          } else if (valuestr == 'Failed') {
            _timer.cancel();
            if (!mounted) return;
            showSnackBar(context, 'Failed to add device. Check your wifi info and try again');
            navigateBack();
          }
        });
      }
    }
  }

  Future<void> writeData(String data, BluetoothCharacteristic? characteristic) async {
    if (characteristic == null) {
      return;
    }

    List<int> bytes = utf8.encode(data);
    await characteristic.write(bytes);
  }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  void navigateBack() {
    Routemaster.of(context).pop();
  }

  void goToStep(AddDeviceSteps addDeviceStep) {
    if (!mounted) return;
    setState(() => setupStep = addDeviceStep);
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    final theme = ref.watch(themeNotifierProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Responsive(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16),
          child: buildSteps(theme),
        ),
      ),
    );
  }

  Widget buildSteps(VisualTheme theme) {
    if (setupStep == AddDeviceSteps.stepOne) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // custom app bar
            Row(
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
                const SizedBox(width: 20),
                const Text(
                  'Add a device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            //wifi information section
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter your Wifi information',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            //ssid textfield
            const SizedBox(height: 20),
            TextField(
              controller: ssidController,
              decoration: InputDecoration(
                hintText: 'SSID',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.wifi,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    AppSettings.openWIFISettings();
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.gear,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Make sure you are connected to 2.4GHz network',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            //password textfield
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                icon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 22,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => isPassVisible = !isPassVisible),
                  icon: const FaIcon(
                    FontAwesomeIcons.eyeSlash,
                    size: 20,
                  ),
                ),
              ),
              obscureText: !isPassVisible,
            ),
            //next button
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => setState(() => setupStep = AddDeviceSteps.stepTwo),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (setupStep == AddDeviceSteps.stepTwo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // custom app bar
          Row(
            children: [
              Ink(
                width: 50,
                height: 50,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  onPressed: () => setState(() => setupStep = AddDeviceSteps.stepOne),
                  splashRadius: 25,
                  icon: const FaIcon(
                    FontAwesomeIcons.chevronLeft,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'Add a device',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select your device below:'),
                !isScanning
                    ? IconButton(
                        onPressed: () {
                          if (!isScanning) {
                            scanDevices();
                          }
                        },
                        icon: const Icon(Icons.refresh),
                      )
                    : const CircularProgressIndicator(color: Colors.black)
              ],
            ),
          ),
          const SizedBox(height: 10),
          //list of devices
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              physics: const BouncingScrollPhysics(),
              itemCount: bluetoothDevicesFound.length,
              itemBuilder: (BuildContext context, int index) {
                // if (bluetoothDevicesFound[index].device.name.contains(targetDevicePrefix)) {
                //   return Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 8),
                //     child: GestureDetector(
                //       onTap: () {
                //         connectToDevice(bluetoothDevicesFound[index].device);
                //         setState(() => setupStep = AddDeviceSteps.stepThree);
                //       },
                //       child: Container(
                //         height: 50,
                //         padding: const EdgeInsets.symmetric(horizontal: 16),
                //         decoration: BoxDecoration(
                //           color: theme.cardBackgroundColor,
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(bluetoothDevicesFound[index].device.name),
                //             Text('${bluetoothDevicesFound[index].rssi} dB'),
                //           ],
                //         ),
                //       ),
                //     ),
                //   );
                // }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      connectToDevice(bluetoothDevicesFound[index].device);
                      setState(() => setupStep = AddDeviceSteps.stepThree);
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bluetoothDevicesFound[index].device.name),
                          Text('${bluetoothDevicesFound[index].rssi} dB'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // custom app bar
        Row(
          children: [
            Ink(
              width: 50,
              height: 50,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: CircleBorder(),
              ),
              child: IconButton(
                onPressed: () => setState(() => setupStep = AddDeviceSteps.stepTwo),
                splashRadius: 25,
                icon: const FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Text(
              'Add a device',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Connecting to device'),
                          isDeviceConnected
                              ? const Icon(Icons.radio_button_checked, color: Colors.green)
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF7F85F9),
                                    strokeWidth: 3,
                                  ),
                                ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Getting device info'),
                          isDeviceInfoGotten
                              ? const Icon(Icons.radio_button_checked, color: Colors.green)
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF7F85F9),
                                    strokeWidth: 3,
                                  ),
                                ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sending credentials'),
                          isCredentialsSent
                              ? const Icon(Icons.radio_button_checked, color: Colors.green)
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF7F85F9),
                                    strokeWidth: 3,
                                  ),
                                ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Connecting to server'),
                          isConnectedToServer
                              ? const Icon(Icons.radio_button_checked, color: Colors.green)
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF7F85F9),
                                    strokeWidth: 3,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
