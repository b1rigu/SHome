import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/features/auth/screens/login_screen.dart';
import 'package:smarthomeuione/features/auth/screens/sign_up_screen.dart';
import 'package:smarthomeuione/features/devices/screens/device_add_screen.dart';
import 'package:smarthomeuione/features/navigation/screens/navigation_screen.dart';
import 'package:smarthomeuione/features/profile/screen/profile_settings_screen.dart';
import 'package:smarthomeuione/features/room/screens/room_add_device_screen.dart';
import 'package:smarthomeuione/features/room/screens/room_add_screen.dart';
import 'package:smarthomeuione/features/room/screens/room_screen.dart';
import 'package:smarthomeuione/features/schedule/screens/schedule_configure_screen.dart';

import 'features/schedule/screens/schedule_add_screen.dart';

final loggedOutRoute = RouteMap(
  onUnknownRoute: (_) => const Redirect('/'),
  routes: {
    '/': (_) => const MaterialPage(child: LoginScreen()),
    '/sign-up': (_) => const MaterialPage(child: SignupScreen()),
  },
);

final loggedInRoute = RouteMap(
  onUnknownRoute: (_) => const Redirect('/'),
  routes: {
    '/': (_) => const MaterialPage(child: NavigationScreen()),
    '/room/:roomId': (route) =>
        MaterialPage(child: RoomScreen(roomId: route.pathParameters['roomId']!)),
    '/room-add-device/:roomId': (route) =>
        MaterialPage(child: RoomAddDeviceScreen(roomId: route.pathParameters['roomId']!)),
    '/room-add': (_) => const MaterialPage(child: RoomAddScreen()),
    '/device-add': (_) => const MaterialPage(child: DeviceAddScreen()),
    '/profile-settings': (_) => const MaterialPage(child: ProfileSettingsScreen()),
    '/schedule-configure/:macId': (route) =>
        MaterialPage(child: ScheduleConfigureScreen(macId: route.pathParameters['macId']!)),
    '/schedule-add/:macId': (route) =>
        MaterialPage(child: ScheduleAddScreen(macId: route.pathParameters['macId']!)),
  },
);
