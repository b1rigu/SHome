import 'package:flutter/material.dart';
import 'package:smarthomeuione/features/home/screens/home_screen.dart';
import 'package:smarthomeuione/features/profile/screen/profile_screen.dart';
import 'package:smarthomeuione/features/scenes/screens/scenes_screen.dart';
import 'package:smarthomeuione/features/schedule/screens/schedule_screen.dart';

class Constants {
  static const googlePath = 'assets/images/google.png';

  static const avatarDefault =
      'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';

  static const tabWidgets = [
    HomeScreen(),
    ScheduleScreen(),
    ScenesScreen(),
    ProfileScreen(),
  ];

  static const roomcategoryIcons = [
    ['bed', Colors.green, Colors.greenAccent],
    ['sofa', Colors.blue, Colors.blueAccent],
    ['bath-tub', Colors.orange, Colors.orangeAccent],
    ['fridge', Colors.red, Colors.redAccent],
  ];
}
