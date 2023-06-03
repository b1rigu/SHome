import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/theme/palette.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
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
        padding: EdgeInsets.only(left: 16, right: 16, top: safePadding + 16),
        child: Column(
          children: [
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
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).logOut();
              },
              style: TextButton.styleFrom(
                elevation: 0,
                backgroundColor: Pallete.primaryMainColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Log out',
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
