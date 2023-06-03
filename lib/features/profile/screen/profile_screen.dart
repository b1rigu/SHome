import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/features/profile/controller/profile_controller.dart';
import 'package:smarthomeuione/features/profile/widgets/mychartwidget.dart';
import 'package:smarthomeuione/models/device_usage_model.dart';
import 'package:smarthomeuione/responsive/responsive.dart';
import 'package:smarthomeuione/theme/palette.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void navigateToSettings(BuildContext context) {
    Routemaster.of(context).push('/profile-settings');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safePadding = MediaQuery.of(context).padding.top;
    final theme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Responsive(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16),
          child: Column(
            children: [
              // custom app bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 24,
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
                      onPressed: () => navigateToSettings(context),
                      splashRadius: 25,
                      icon: const Icon(
                        Icons.settings,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePic),
                        radius: 45,
                      ),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Pallete.primaryMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const EnergyConsumption(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Pallete.primaryMainColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.extension_sharp),
                    SizedBox(width: 10),
                    Text(
                      'Extra Features',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnergyConsumption extends ConsumerStatefulWidget {
  const EnergyConsumption({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EnergyConsumptionState();
}

class _EnergyConsumptionState extends ConsumerState<EnergyConsumption> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Pallete.primaryMainColor,
      ),
      padding: const EdgeInsets.all(16),
      child: ref.watch(getGraphDataProvider).when(
            data: (map) {
              final List<DeviceUsageModel> deviceUsageList = map['deviceUsageList'];
              final double usageOfToday = map['usageOfToday'];
              final double usageOfThisMonth = map['usageOfThisMonth'];
              final double urtug = map['urtug'];
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (deviceUsageList.isEmpty)
                    const Text(
                      'No data to graph',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  if (deviceUsageList.isNotEmpty) MyChartWidget(deviceUsageList: deviceUsageList),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildConsumption(
                            icon: FontAwesomeIcons.bolt,
                            text: 'Today',
                            usage: usageOfToday,
                            prefix: 'kWh'),
                        buildConsumption(
                            icon: FontAwesomeIcons.plug,
                            text: 'This month',
                            usage: usageOfThisMonth,
                            prefix: 'kWh'),
                      ],
                    ),
                  ),
                  buildConsumption(
                    icon: FontAwesomeIcons.plug,
                    text: 'This month',
                    usage: urtug,
                    prefix: 'Tugrug',
                  ),
                ],
              );
            },
            error: (error, _) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }

  Widget buildConsumption({
    required IconData icon,
    required String text,
    required double usage,
    required String prefix,
  }) {
    return Row(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${usage.toStringAsFixed(3)} $prefix',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
