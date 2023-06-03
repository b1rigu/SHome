import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/features/mqtt/repository/mqtt_repository.dart';

class SmartPlug extends ConsumerStatefulWidget {
  final String macId;
  const SmartPlug({super.key, required this.macId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SmartPlugState();
}

class _SmartPlugState extends ConsumerState<SmartPlug> {
  late MQTTRepository repo;
  bool btnstate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      repo = ref.read(mqttProvider);
      repo.subscribe('${widget.macId}/send');
    });
  }

  void switchButton(bool value) {
    // if (!isLoading) {
    //   setState(() {
    //     isLoading = true; // your loader has started to load
    //   });
    //   repo.publish(value.toString(), '${widget.device.macId}/receive');
    // }
    repo.publish(value.toString(), '${widget.macId}/receive');
    setState(() {
      btnstate = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getDeviceByMacIdProvider(widget.macId)).when(
          data: (device) {
            return Column(
              children: [
                Container(
                  height: 90,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CupertinoSwitch(
                            activeColor: const Color(0xFF7F85F9),
                            value: btnstate,
                            onChanged: (value) => switchButton(value),
                          ),
                          const Text(
                            '0kWh',
                            style: TextStyle(
                              color: Color(0xFFF9B23D),
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.plugCircleBolt,
                      size: 200,
                      color: btnstate ? const Color(0xFF7F85F9) : Colors.grey,
                    ),
                  ],
                ),
              ],
            );
          },
          error: (error, _) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
