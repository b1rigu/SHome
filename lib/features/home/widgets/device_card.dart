import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/features/mqtt/repository/mqtt_repository.dart';
import 'package:smarthomeuione/models/device_model.dart';
import 'package:smarthomeuione/theme/palette.dart';

class DeviceCard extends ConsumerStatefulWidget {
  final DeviceModel device;
  const DeviceCard({super.key, required this.device});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends ConsumerState<DeviceCard> {
  final nameController = TextEditingController();
  late MQTTRepository repo;
  late StreamSubscription streamSubscription;

  List<String> btnAddressesPlugExtender = [
    'switch0',
    'switch1',
    'switch2',
    'switch3',
    'mainswitch'
  ];
  List<String> btnNamesPlugExtender = ['Switch 1', 'Switch 2', 'Switch 3', 'Switch 4'];
  String usage = '0.00';
  List<bool> btnstate = [false, false, false, false, false];
  bool isMainSwitchOn = false;
  bool isLoading = false;
  bool isDeviceonline = false;
  int count = 21;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      repo = ref.read(mqttProvider);
      repo.subscribe('${widget.device.macId}/status');
      repo.subscribe('${widget.device.macId}/usage');
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (count > 20) {
          isDeviceonline = false;
        } else {
          isDeviceonline = true;
        }
        setState(() => count++);
      });
      final mqttSubscriptionStream = ref.read(mqttProvider).getSubscriptionStream();
      streamSubscription =
          mqttSubscriptionStream.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String mqttpayload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final String mqtttopic = c[0].topic;
        if (mqtttopic == '${widget.device.macId}/status') buttonState(mqttpayload);
        if (mqtttopic == '${widget.device.macId}/usage') usageUpdate(mqttpayload);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
    nameController.dispose();
    _timer.cancel();
  }

  void usageUpdate(String newUsage) {
    setState(() {
      usage = newUsage;
    });
  }

  void buttonState(String status) {
    if (widget.device.type == 'PlugExtenderFour') {
      List<String> statusList = status.split(",");
      isMainSwitchOn = statusList[4] == '0' ? false : true;
      for (int i = 0; i < 5; i++) {
        btnstate[i] = statusList[i] == '1' ? true : false;
      }
    } else if (widget.device.type == 'Plug') {
      btnstate[0] = status == '1' ? true : false;
    }
    setState(() {
      count = 0;
      isLoading = false;
    });
  }

  void switchButton(bool value, String topic, int index) {
    repo.publish(value ? '1' : '0', topic);
    setState(() {
      isLoading = true;
      // btnstate[index] = !btnstate[index];
    });
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
              onPressed: () => deleteDevice(),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
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

  void deleteDevice() {
    ref.read(devicesControllerProvider.notifier).deleteDevice(widget.device, context);
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
        height: 165,
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            customDeviceWidget(),
            !isDeviceonline
                ? Container(
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Offline',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget customDeviceWidget() {
    if (widget.device.type == 'Plug') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    const SizedBox(width: 10),
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
                        Text(
                          '⚡ $usage W',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                buttonBuilder(btnstate[0], 'receive', 0, 'Switch main'),
              ],
            ),
          ],
        ),
      );
    } else if (widget.device.type == 'PlugExtenderFour') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          FontAwesomeIcons.plugCirclePlus,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                        Text(
                          '⚡ $usage W',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //device on or off state
                buttonBuilder(btnstate[4], 'mainswitch', 4, 'Switch main'),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return buttonBuilder(
                        btnstate[index],
                        btnAddressesPlugExtender[index],
                        index,
                        btnNamesPlugExtender[index],
                      );
                    }),
                  ),
                  !isMainSwitchOn
                      ? Container(
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Main switch off',
                              style: TextStyle(color: Colors.white, fontSize: 26),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget buttonBuilder(bool valueb, String sendAddress, int index, String buttonName) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CupertinoSwitch(
                activeColor: const Color(0xFF7F85F9),
                value: valueb,
                onChanged: (value) {
                  switchButton(value, '${widget.device.macId}/$sendAddress', index);
                },
              ),
              if (isLoading)
                const CircularProgressIndicator(
                  color: Color(0xFF7F85F9),
                ),
            ],
          ),
        ),
        Text(
          buttonName,
          style: const TextStyle(fontSize: 10),
        )
      ],
    );
  }
}
