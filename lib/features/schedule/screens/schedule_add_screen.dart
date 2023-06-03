import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/features/mqtt/repository/mqtt_repository.dart';
import 'package:smarthomeuione/features/schedule/controller/schedule_controller.dart';
import 'package:smarthomeuione/features/schedule/widgets/hours.dart';
import 'package:smarthomeuione/features/schedule/widgets/minutes.dart';
import 'package:smarthomeuione/features/schedule/widgets/on_or_off.dart';
import 'package:smarthomeuione/theme/palette.dart';

class ScheduleAddScreen extends ConsumerStatefulWidget {
  final String macId;
  const ScheduleAddScreen({super.key, required this.macId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScheduleAddScreenState();
}

class _ScheduleAddScreenState extends ConsumerState<ScheduleAddScreen> {
  FixedExtentScrollController controllerone = FixedExtentScrollController();
  FixedExtentScrollController controllertwo = FixedExtentScrollController();
  FixedExtentScrollController controllerthree = FixedExtentScrollController();
  FixedExtentScrollController controllerfour = FixedExtentScrollController();
  late MQTTRepository repo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      repo = ref.read(mqttProvider);
    });
  }

  void submit() async {
    String whichDevice = controllerfour.selectedItem.toString();
    String isOn = controllerthree.selectedItem == 0 ? '1' : '0';
    String selectedHour = controllerone.selectedItem.toString();
    if (controllerone.selectedItem < 10) selectedHour = '0$selectedHour';
    String selectedMinute = controllertwo.selectedItem.toString();
    if (controllertwo.selectedItem < 10) selectedMinute = '0$selectedMinute';
    String time = '$selectedHour:$selectedMinute';
    repo.publish('$time.$whichDevice$isOn', '${widget.macId}/scheduleSet');
    Routemaster.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    controllerone.dispose();
    controllertwo.dispose();
    controllerthree.dispose();
    controllerfour.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16, bottom: 16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    child: ListWheelScrollView.useDelegate(
                      controller: controllerone,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24,
                        builder: (context, index) {
                          return MyHours(hours: index);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: controllertwo,
                            onSelectedItemChanged: (value) {},
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (context, index) {
                                return MyHours(hours: index);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: ListWheelScrollView.useDelegate(
                      controller: controllerthree,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 2,
                        builder: (context, index) {
                          return OnOff(onOff: index == 0 ? true : false);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: controllerfour,
                            onSelectedItemChanged: (value) {},
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 4,
                              builder: (context, index) {
                                return MyMinutes(mins: index);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => submit(),
              style: TextButton.styleFrom(
                elevation: 0,
                backgroundColor: Pallete.primaryMainColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
