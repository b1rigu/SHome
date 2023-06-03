import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:smarthomeuione/core/common/rive_utils.dart';
import 'package:smarthomeuione/core/constants/constants.dart';
import 'package:smarthomeuione/features/navigation/widgets/animated_bar.dart';
import 'package:smarthomeuione/models/riveasset_model.dart';
import 'package:smarthomeuione/responsive/responsive.dart';
import 'package:smarthomeuione/theme/palette.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  RiveAsset selectedBottomNav = bottomNavs.first;
  int _page = 0;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Constants.tabWidgets[_page],
      bottomNavigationBar: SafeArea(
        child: Responsive(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3442),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      bottomNavs[index].input!.change(true);
                      if (bottomNavs[index] != selectedBottomNav) {
                        setState(() {
                          selectedBottomNav = bottomNavs[index];
                          _page = index;
                        });
                      }
                      Future.delayed(const Duration(seconds: 1), () {
                        bottomNavs[index].input!.change(false);
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBar(isActive: bottomNavs[index] == selectedBottomNav),
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: Opacity(
                            opacity: bottomNavs[index] == selectedBottomNav ? 1 : 0.5,
                            child: RiveAnimation.asset(
                              bottomNavs.first.src,
                              artboard: bottomNavs[index].artboard,
                              onInit: (artboard) {
                                StateMachineController controller = RiveUtils.getRiveController(
                                  artboard,
                                  stateMachineName: bottomNavs[index].stateMachineName,
                                );
                                bottomNavs[index].input = controller.findSMI('active') as SMIBool;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
