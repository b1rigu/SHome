import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/common/loader.dart';
import '../../../theme/palette.dart';

class ScheduleConfigureScreen extends ConsumerStatefulWidget {
  final String macId;
  const ScheduleConfigureScreen({super.key, required this.macId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScheduleConfigureScreenState();
}

class _ScheduleConfigureScreenState extends ConsumerState<ScheduleConfigureScreen> {
  void navigateToAdd() {
    Routemaster.of(context).push('/schedule-add/${widget.macId}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final safePadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16, bottom: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => navigateToAdd(),
                    style: TextButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Pallete.primaryMainColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Create schedule',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder(
              stream: FirebaseDatabase.instance.ref('devices/${widget.macId}/schedule').onValue,
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return const Loader();
                }
                if (snapshot.data!.snapshot.value != null) {
                  final data = snapshot.data!.snapshot.value as String;
                  List<String> schedules = data.split(',');

                  return Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = {
                          'relayIndex': int.parse(schedules[index].substring(6, 7)) + 1,
                          'onOrOff': int.parse(schedules[index].substring(7)),
                          'time': schedules[index].substring(0, 5),
                        };

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(child: Icon(Icons.access_alarm)),
                              ),
                              const SizedBox(width: 10),
                              Text('Relay: ${map['relayIndex']}'),
                              const SizedBox(width: 10),
                              map['onOrOff'] == 0
                                  ? const Text('State: Off')
                                  : const Text('State: On'),
                              const SizedBox(width: 10),
                              Text('Time: ${map['time']}'),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
