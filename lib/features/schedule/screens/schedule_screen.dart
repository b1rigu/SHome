import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/features/devices/controller/devices_controller.dart';
import 'package:smarthomeuione/features/schedule/widgets/schedule_device_card.dart';
import 'package:smarthomeuione/responsive/responsive.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final yourScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    return Responsive(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ref.watch(userDevicesProvider).when(
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
                              child: ScheduleDeviceCard(device: data[index]),
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
